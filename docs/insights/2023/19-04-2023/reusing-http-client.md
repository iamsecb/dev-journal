---
title: Go Reusing HTTP Client
tags:
  - api-design
  - go
  - client
---

## Clear APIs and reusing the http client

When designing an API it is critical to consider the usability of the API from the user's or developer's perspective. With this requirement in mind, when designing the usage of a HTTP client for a service, which may have  multiple sub-services, it is useful to provid a scoped API yet reuse the same HTTP client.

I was looking for a pattern to do this and found the following library solving this in an interesting way:

<https://github.com/raksul/go-clickup/blob/main/clickup/client.go>

Let's look at the interesting bits.

Declartion in `NewClient()` with my comments:

```go
// Define a client. Nothing new here.
c := &Client{client: httpClient, BaseURL: baseURL, UserAgent: userAgent, APIKey: APIKey}
// Now assign the client to common.
c.common.client = c
// We don't want to allocate to the heap so we assign the address of c.common to c.Attachments after casting
// it as a pointer to AttachmentsService.
// This means that c.Attachments now references the same object in memory as c.common.
c.Attachments = (*AttachmentsService)(&c.common)
// Do the same for all the sub-services.
c.Authorization = (*AuthorizationService)(&c.common)
c.Checklists = (*ChecklistsService)(&c.common)
c.Comments = (*CommentsService)(&c.common)
...
```

Corresponding defnitions for above code:

```
type service struct {
        client *Client
}


type AttachmentsService service


type Client struct {
        clientMu sync.Mutex   // clientMu protects the client during calls that modify the CheckRedirect func.
        client   *http.Client // HTTP client used to communicate with the API.
        APIKey   string

        BaseURL   *url.URL
        UserAgent string

        rateMu     sync.Mutex
        rateLimits Rate // Rate limits for the client as determined by the most recent API calls.

        common service // Reuse a single struct instead of allocating one for each service on the heap.

        // Services used for talking to different parts of the Clickup API.
        Attachments     *AttachmentsService
		Authorization   *AuthorizationService
		Checklists      *ChecklistsService
		Comments        *CommentsService
		...
}
```

This can be illustrated as shown below (for `Attachments`):

![reuse-client](../images/reuse-client.drawio)

The takeaway being you can typecast and assign the memory address of `common` to `Attachments` because they have
the same `Client` type.

The API is now accessible as shown in the following pseudocode:

```
c := NewClient()
c.Attachments.* // Attachments specific APIs 
c.Comments.* // Comments specific APIs
```