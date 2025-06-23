---
tags:
  - terraform
---

# Q&A

### What are 3 ways you can use a data source?


There are a few different ways data sources can be used:

Referencing a resource managed by Terraform:

```
resource "aws_s3_bucket" "example" {
  # ...
}

data "aws_s3_bucket" "example" {
  bucket = aws_s3_bucket.example.id 
}
```



Here the data source is looking up attributes of the S3 bucket managed in this Terraform configuration.

```
Referencing resources not managed by Terraform:
data "aws_s3_bucket" "existing" {
  bucket = "my-existing-bucket" 
}
```

Here the data source is fetching data about an S3 bucket that already exists outside of Terraform.

Lookup based on filters:

```
data "aws_ami" "app" {
  filter {
    name = "name"
    values = ["app-ami-*"]
  }
}
```


Here the data source will find the latest AMI that matches the given filter criteria.

So in summary - data sources can reference Terraform resources, external resources not managed by Terraform, or lookup resources based on criteria like tags or filters. They don't strictly require a Terraform resource reference.
