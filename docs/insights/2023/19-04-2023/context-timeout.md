---
title: Go Context Timeout
tags:
  - go
  - client
  - context
---

## When does the `contex.Context` cancel for `WithTimeout()` ?

If you have `funcA()` calling `funcB()` with a context timeout, the timer starts from the time the context is created and you will get a `DeadlineExceeded` error if the timer expires.

typically you add a `defer cancel()` to ensure there is no context leak. If you are calling `funcB()` via a goroutine you must wrap the `defer cancel()` inside the goroutine. Otherwise, you will get `DeadlineExceeded` error.

Example

```go
package main

import (
	"context"
	"fmt"
	"time"
)

func funcA() {
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*3)
	go func() {
		defer cancel() // Defer canceling the context
		funcB(ctx)
	}()
}

func funcB(ctx context.Context) {
	select {
	case <-time.After(2 * time.Second):
		// Do something that takes more than 2 seconds
		fmt.Println("Work for 2 seconds")
	case <-ctx.Done():
		// Context canceled or timed out
		if ctx.Err() == context.DeadlineExceeded {
			fmt.Println(context.DeadlineExceeded)
		} else {
			fmt.Println(ctx.Err())
		}
	}

}
func main() {
	funcA()
	time.Sleep(time.Second * 3)

}
```