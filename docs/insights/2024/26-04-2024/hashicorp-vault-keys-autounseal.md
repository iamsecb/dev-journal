---
tags:
  - hashicorp
  - vault
title: Hashicorp Vault Keys for Autounseal
---

The first thing to remember is that when Vault starts, it is in a **Sealed** state. 

#### What does **Sealed** state mean?

By configuration Vault knowns where and how to access the physical storage of secrets but cannot decrypt them. So it must be unsealed. This would mean it is encrypted in someway. Spot on, it is formally referred to as the **Root key**.

This leads us back to unsealing, which is the process of getting access to the plaintext Root key. And why to do we need the Root key? because all data is encrypted with an Encryption key that is derived from the Root key.

> Unsealing is the process of getting access to the plaintext Root key.

#### Ok, So where does the Root key come from?

The root key is stored alongside other vault data. Which means from a security standpoint, it needs to be encrypted at rest. 

#### So there's another key to encrypt the Root key?

Yes, this is where the **Unseal Key** is relevant. The auto unseal feature delegates responsibility of securing the Unseal key to a trusted device or system. At startup Vault will connect to the device or system and ask it to decrypt the Root key it read from storage.

#### What is the Root token then?

Root tokens are tokens that have the root policy attached to them. Root tokens can do anything in Vault. *Anything*.

There are 3 ways root token can exist:

1. When vault is initialised via `vault operation init`
2. Using an existing root token to create another 
3. By running `vault operator generate-root` using the Recovery keys


#### What are Recovery keys?

There are certain operations in Vault that require explicit authorization for it to be performed. For example, unsealing Vault or generating a Root token. When using Autounseal, this requires **Recovery keys**. 

#### How do we get the Recovery keys?

When Vault is first initialised via Autounseal, it yield Recovery keys from the Root key. In other words, the Root key is split into a series of key shares following Shamir's Secret Sharing Algorithm.

One of the first operational activities is to initialise Vault by running `vault operator init`. This will generate the Root key, the Recovery keys (as desribed) and the Root token.

The process of generating a new Root key is called **Rekeying**.


#### Explain [Rekeying](https://developer.hashicorp.com/vault/tutorials/operations/rekeying-and-rotating#rekeying-vault)?

> The process for generating a new root key and applying Shamir's algorithm is called "rekeying"

```
$vault operator rekey -target=recovery -init -key-shares=5 -key-threshold=3

WARNING! If you lose the keys after they are returned, there is no recovery.
Consider canceling this operation and re-initializing with the -pgp-keys flag
to protect the returned unseal keys along with -backup to allow recovery of
the encrypted keys in case of emergency. You can delete the stored keys later
using the -delete flag.

Key                      Value
---                      -----
Nonce                    e0bd8648-0f8a-8641-bc18-2b4158d406a9
Started                  true
Rekey Progress           0/3
New Shares               5
New Threshold            3
Verification Required    false
```

Provide the Recovery keys to meet the key threshold. One example is shown below:

```
$ vault operator rekey -target=recovery

Rekey operation nonce: e0bd8648-0f8a-8641-bc18-2b4158d406a9
Unseal Key (will be hidden):
Key                      Value
---                      -----
Nonce                    e0bd8648-0f8a-8641-bc18-2b4158d406a9
Started                  true
Rekey Progress           1/3
New Shares               5
New Threshold            3
Verification Required    false
```

Once all 3 Recovery keys have been applied, it will generate new Recovery keys from the new Root key.

#### How do we generate a new Root token?

A [new](https://developer.hashicorp.com/vault/tutorials/operations/generate-root) Root token can be created with the Recovery keys.

```
$ vault operator generate-root -init
A One-Time-Password has been generated for you and is shown in the OTP field.
You will need this value to decode the resulting root token, so keep it safe.
Nonce         c6f98535-43de-cd7b-d4d4-fd8fb17fd381
Started       true
Progress      0/3
Complete      false
OTP           BJ4MR81PaVRw7fjLZqBti5H7dkiS
OTP Length    28
```

Provide the Recovery keys to meet the key threshold. One example is shown below:

```
vault operator generate-root
Operation nonce: c6f98535-43de-cd7b-d4d4-fd8fb17fd381
Unseal Key (will be hidden):
Nonce       c6f98535-43de-cd7b-d4d4-fd8fb17fd381
Started     true
Progress    1/3
Complete    false
```

Once all 3 Recovery keys have been supplied, it will provided the encoded Root token as shown below:

```
vault operator generate-root
Operation nonce: c6f98535-43de-cd7b-d4d4-fd8fb17fd381
Unseal Key (will be hidden):
Nonce            c6f98535-43de-cd7b-d4d4-fd8fb17fd381
Started          true
Progress         3/3
Complete         true
Encoded Token    KjxHYxxhXB1ZDwQuQVcgOi8HOhUfWS5BDgYbGA
```

The OTP from step 1 can be used to decode the Root token.

```
vault operator generate-root \
> -decode=KjxHYxxhXB1ZDwQuQVcgOi8HOhUfWS5BDgYbGA \
> -otp=BJ4MR81PaVRw7fjLZqBti5H7dkiS
```


> To recap: most Vault data is encrypted using the encryption key in the keyring; the keyring is encrypted by the root key; and the root key is encrypted by the unseal key.


```
vault operator generate-root \
 -decode=OgUXeGpAYHYIPRFaAQcsDgYQDQIdJRM9V3M8KQ \
 -otp=RsdV3r8BCIIlMnXbCiZLJtbyg2Nj
```


