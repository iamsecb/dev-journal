---
title: Vault K8s Auth
tags:
  - vault
  - k8s
---

#### When you create a ServiceAccount does it automatically create a token?

#### What is the `TokenReview API` return values?

#### How is the `aud` claim used for SA tokens and Vault?

#### What are the configuration details for auth/jwt/config API?

#### What is the threat model?

https://developer.hashicorp.com/vault/docs/auth/kubernetes
 
> The pattern Vault uses to authenticate Pods depends on sharing the JWT token over the network. Given the security model of Vault, this is allowable because Vault is part of the trusted compute base. In general, Kubernetes applications should not share this JWT with other applications, as it allows API calls to be made on behalf of the Pod and can result in unintended access being granted to 3rd parties.


#### What is the Authentication method?

https://developer.hashicorp.com/vault/docs/auth/jwt/oidc-providers/kubernetes#use-service-account-issuer-discovery

Service Account issuer discovery as per:

https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-issuer-discovery


- Endpoint must be unauthenticated to federate with Vault
- `oidc_discovery_url` and if custom CA certs are used `oidc_discovery_ca_pem` must be provided
- 



#### What are the token security features?

#### What course of action to take if the OIDC discovery URL is not public?


### Why should the `iss` claim be validated against the issuer URL?

### What is the difference between `RSA` or `ECDSA` certificate?

https://go.dev/blog/tls-cipher-suites

### What is the purpose of a ciphersuite?


### Confidentiality vs. Integrity

 onfidentiality is provided via encryption, while Integrity is provided via MAC.


### Public key trust

You should be able to trust the public key this is why certificate verification is important.






As per the spec:

issuer URL == issuer value 
issue claim == issuer value





### Why is `aud` claim important?


### Why is `sub` claim validation important?

- Avoid misuse

  Say a token has subject `app-service-account-1` and someone attempt to access a resource meant for `app-service-account-2`, even
  though the signature validation will pass, the `sub` validation will fail. This prevents misuse of a valid token.

- Token replay 
  If an attacker steals a token with subject `app-service-account-1` and attempts to access resources for `app-service-account-2`, even though signature verification will pass, bound claim validation will fail. 


#### Why is `sub` claim validation required if signature verification takes place?

Signature verification provides an integrity check while the subject verifies the entity. This ensure only specific SAs can access specific roles.









### Commands

1. How to find issuer?

 kubectl get --raw /.well-known/openid-configuration | jq -r '.issuer'



