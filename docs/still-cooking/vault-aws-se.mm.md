---
title: Vault AWS SE
markmap:
  colorFreezeLevel: 3  
---
# Vault AWS SE

This is a collection of resources to skill up in Cloud and Backend Engineering.

!!! note

	This list is a work in progress.



{!wip/vault-aws-se.mm.md!}

----


## IAM User

### Result

- access key ID and secret access key

### Expiry

- Lease applies if configured and will expire

### Config 

- IAM user creds 
- Dynamically creates users 

### Expiry

- The lease is set at the root config level
- Users are deleted at the end of the lease


## [Federation Token](https://docs.aws.amazon.com/STS/latest/APIReference/API_GetFederationToken.html)

### Result
- Temporary access key ID, a secret access key, and a security token

### Config 
- You must call the API operation using long-term creds of an IAM user

### Expiry
- Can be set at the role configuration 

### Use case 
- Proxy application that gets creds on behalf of distributed apps inside a coporate network

### Limitations
- Cannot call IAM API
- Can only call `GetCallerIdentity` of STS API
- Must pass in-line or managed policy 
- Intersection of the IAM user policy and session policy which can be furter restricted 
- Max permissions are limited to the IAM user policy 

## STS Session Tokens 

### Result

- Temporary access key ID, a secret access key, and a security token

### Config 
- You must call the API operation using long-term creds of an IAM user

### Expiry
- Can be set at the role configuration 

### Use case 
- Session tokens may also require an MFA-based TOTP to be provided if the IAM user is configured to require it

### Limitations
- Inherits all or any permissions of the IAM user of root config 
- assigning a role or policy is disallowed 
- IAM API can **only** if MFA details are included

## Differences 

### STS Session vs. Ferderated token

#### Federated tokens 
- Can be configured with additional policies or roles
- IAM API cannot be called

#### STS session tokens 
- Inherits the root config IAM user policy. No further policies can be attached.

#### Assume role
- Can invoke STS and IAM API if the assume role's policy grants it 
- Cross account authentication 



## References 

- [Request temp security Credentials](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html)

## Root config

- Must contain IAM user creds 
- Should run the rotate command so Vault auto rotates the creds 
- All of the role types depend on the root config IAM user
-