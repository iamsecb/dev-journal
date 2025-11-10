---
tags:
  - mfa
---

# YubiKey and Passkeys

Let's begin by outlining that the MFA factors are:

<b>

1. Something you have e.g. YubiKey, smartphone

2. Something you know e.g. password, PIN

3. Something you are e.g. fingerprint, facial recognition etc.
</b>

> All 2FA is MFA.

It's worth re-iterating that meeting 2 of the above criteria satisfies the requirements for 2FA, which is a subset of MFA.

In practical terms, this means that if a user provides both a YubiKey (something they have) and a password (something they know), they are meeting the 2FA requirements.

## What is the difference between YubiKey and Passkey?

While Passkey is software based, YubiKey is a hardware-based authentication method. This means that YubiKey requires a physical device to be present for authentication, while Passkey can be used on any device that supports it, without the need for additional hardware.

## Passwordless

While passwordless authentication eliminates the need for traditional passwords, it still relies on other factors to verify a user's identity. This could be the user's device (something they have) or something they know like a PIN. 

So while passwordless authentication removes the password from the equation, it doesn't eliminate the need for other forms of verification. Users may still need to satisfy the 2 factors of authentication for MFA.






