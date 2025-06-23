---
title: Adapter Pattern
tags:
  - api-design
  - go
---

An interesting article that describes the need for the adapter pattern.

<https://bitfieldconsulting.com/golang/adapter>

Some takeways:

- As the article states "*Dependency expertise and business logic don’t mix*" because it creates 2 problems; impacts
  testability and violates the single responsibility principle by breaching the scope of interest for that particular function. In the example, this is represented by mixing implementation details of a database in a function that deals with business logic.

- An adapter abstracts the implementation details away from the business logic. 
	
	In the above example, defining an interface solves the issue.This would allow us to completely decouple the need for a real endpoint.

	```go
	type Store interface {
		Store(Widget) (string, error)
	}
	```

- Test inputs and outputs.  

  	With an adapter, you want to ensure the data supplied as input will
  	produce a valid result. On the same note, the return value or the output is in the format you expect it to be in.  This can be difficult to test without running a real system (e.g: database). One solution to bridge this gap is to use a mocking library. Even this may have limitation as you are still mocking the data and the real data
  	might be different. However, you eventually will need to perform an integration test with a real system. If if it succeeds, you have shifted-left by having higher confidence that your tests will make the program work as expected. If it fails, it helps to adjust your assumption about how you thought it should work and fix the tests accordingly.