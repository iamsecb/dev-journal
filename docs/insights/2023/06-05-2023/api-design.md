---
title: API Design
tags:
  - api-design
---

### Designing a simple API client

A weather client as per <https://bitfieldconsulting.com/golang/api-client>

Some takeaways:

- Determine what to test by inputs and outputs.
- Put any mock data for tests in `testdata`.
- when dealing API responses, you must guard against results that are **unexpectedly empty**, **incomplete**, **invalid**, or has the **wrong schema**. 
- A quote worth remembering:
  
    > Don’t test other people’s code: test that your code does the right thing when theirs doesn’t.

- Avoid "*paperwork*". For example, why get something from one function just to pass it to another? The API should be
  simple for a developer to consume.

