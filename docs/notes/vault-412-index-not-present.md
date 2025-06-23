---
title: Vault 412 Index Not Present
tags:
  - vault
---

### What's the problem?

The following error is returned when trying to retrieve a secret via a GitLab pipeline:

> 412 required index state not present

### What do we know so far?

Based on preliminary observation it appears that:

1. When a secret is added or updated or even a configuration change is made and the secret is retrieved via the pipeline, the 412 error is intermittently returned
2. The error can return even after approximately 2mins of adding/updating the secret
3. Reproducible in dev and prod

### What can we do to isolate the problem further?

1. Attempt to set `VAULT_MAX_RETRIES` to a very high threshold 
	- Tested adding a secret and running the pipeline immediately which failed. On subsequent re-runs of the pipeline it worked. 
2. Retrieve the GitLab ID token, login locally and attempt to retrieve the secret in a loop to identify failure rate
	- Can confirm that running a curl command occasionally returns a `index not present` error	
3. Ensure the clock time is in sync
3. Identify if there are any latency metrics we can look at
4. Enable trace logs 

----

### What is known about this behaviour?

The  [Server Side Consistent Tokens feature](https://developer.hashicorp.com/vault/docs/faq/ssct#q-what-is-the-server-side-consistent-token-feature) introduced in v1.10 embeds the WAL index
in the token to allow performance standby nodes to check the token locally against its index. If 
the request made to the node cannot support read-after-write consistency because WAL index for 
the token does not match, it will result in a 412 index not present.

The key point is:

> Unless there is a considerable replication delay, Vault clients experience read-after-write consistency.

In our case given that the issue appears to surface even after ~2mins, it is likely there is an actual 
replication delay. Either that or there are genuine changes occurring causing the WAL to change and the client
is not retrying.







