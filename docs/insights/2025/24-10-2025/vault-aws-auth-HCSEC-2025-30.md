---
tags:
  - aws 
  - vault
---

# Vault AWS Auth Method Security Advisory (HCSEC-2025-30)

## Summary

Vault’s STS verification step succeeded (STS proves who signed the request), but Vault’s subsequent authorization/matching logic failed to enforce the account/ARN constraints strictly in some wildcard scenarios, allowing a different-account role with a matching role-name pattern to be accepted.

## Attack Scenario

1. An attacker configures an IAM role in their account.
2. The attacker signs a `GetCallerIdentity` request with that role’s credentials.
3. The attacker sends the signed request to the victim Vault’s AWS Auth endpoint.
4. Vault forwards/verifies the signed request with AWS STS. *As far as Authentication is concerned, it passes.*
5. AWS STS validates the signature and returns the canonical caller identity for the attacker’s role (so STS “authenticates” the request).
6. Vault receives a valid STS response and — due to the vulnerable matching logic for bound_principal_iam/wildcard patterns — incorrectly authorizes the attacker. *So it fails Authorisation*.
