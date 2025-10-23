---
tags:
  - ssl
  - faq
title: SSL Certs
---

## Primer 

SSL certificates provide 2 distinct functions:

- **Authenticity** - "Who am I connecting to?"
- **Privacy** - "Is my data private?" i.e. encrypted.

### What is PKI?

Public Key Infrastructure (PKI) is a framework that enables secure communication and authentication over networks using a combination of public and private cryptographic keys. It involves the use of digital certificates, certificate authorities (CAs), and a set of policies and procedures to manage the creation, distribution, and revocation of these certificates.

To break it down further it has the following components:

1.**Certificate Authority (CA)**: A trusted entity that issues digital certificates. CAs verify the identity of entities (individuals, organizations, or devices) before issuing certificates.
2. **Registration Authority (RA)**: An entity that acts as an intermediary between the user and the CA. The RA is responsible for accepting requests for digital certificates and authenticating the entity making the request.
3. **Public/Private Key Pair**: Each entity has a pair of cryptographic keys - a public key and a private key. The public key is shared with others, while the private key is kept secret. Data encrypted with the public key can only be decrypted with the corresponding private key, and vice versa.
4. **Digital Certificates**: These are electronic documents that bind a public key to an entity's identity
  (e.g., a person or organization). Certificates are issued by CAs and contain information such as the entity's name, public key, expiration date, and the CA's digital signature.
5. **Certificate Store** - A repository where trusted CA certificates are stored. This store is used by clients to verify the authenticity of digital certificates presented by servers during secure communications.


## FAQ

### How is a certificate validated?

1. The domain name in the URL must match the domain name in the certificate.
2. The certificate must be within its validity period (not expired).
3. The certificate must be signed by a trusted Certificate Authority (CA).


### Does the server send the intermediate CA certs in the SSL handshake?

Short answer: Yes.

See [this StackOverflow answer](https://security.stackexchange.com/a/93159).

As per the RFC:

```
certificate_list
  This is a sequence (chain) of certificates.  The sender's
  certificate MUST come first in the list.  Each following
  certificate MUST directly certify the one preceding it.  Because
  certificate validation requires that root keys be distributed
  independently, the self-signed certificate that specifies the root
  certificate authority MAY be omitted from the chain, under the
  assumption that the remote end must already possess it in order to
  validate it in any case.
```

### Is the Root CA cert also sent by the server?

It may not. The RFC says:


> The self-signed certificate that specifies the root certificate authority MAY be omitted from the chain, under the assumption that the remote end must already possess it in order to validate it in any case.

So the client must have the Root CA cert installed in its trust store. Typically, all major Root CA 
certificates are bundled into the client.

### How do I view the certs sent by the server?

```
openssl s_client -connect google.com:443 -showcerts < /dev/null 2>/dev/null
```

### How does the server send the CA certs?

It is bundled into what's known as the fulll certificate chain.  As shown in the example below, the server certificate must come first, followed by any intermediary CA certs.

```
cat server_cert.pem intermediate1.pem intermediate2.pem > fullchain.pem
```

### What is the default path to the intermediate CA certs?

The default path is `/etc/ssl/certs/ca-certificates.crt` on Debian and Ubuntu.

### What is the Chain of Trust?

In the SSL handshake, when the browser receives the server's certificate, it needs to check if the certificate is signed by a trusted CA. The process of how this happens is outlined below.

1. During the handshake, the client looks at the leaf certificate, which is typically signed by an intermediate CA.
2. The browser will look for the public certificate of the intermediate CA to verify the signature of the leaf certificate. If it already exists in the trust store, it can immediately complete signature verification by using the CA's public key. 
3. If the intermediate CA's public key is not found in the trust store, the browser must get the intermediate CA certificate via the certificate list in the leaf cert by looking at the issuer. 
4. The browser would now have to verify the signature for the intermediate CA (via the parent CA that signed the intermediate CA cert) to complete the chain of trust. The browser can identify the issuer of the intermediate CA cert by searching in its trust store for the public cert of the issuer. If it finds it, it will use it to verify the signature of the intermediate CA cert which completes the chanin of trust.
5. If it is not found in the trust store, step 3-4 will be repeated. This process stops when the browser either has the public key of the top-level intermediate CA that signed the intermediate CA to the leaf certificate or the issuer is the Root CA and verifies the signature because it has the Root CA public key in its trust store.

If any step fails in this process (e.g., a certificate is expired, revoked, or the signature is invalid), the client will not trust the certificate, and the connection may be terminated or a warning message displayed.

### How do you retrieve the certificates from a domain programatically?

```
openssl s_client -showcerts -connect  foo.com -servername  foo.com  </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > foo.com.pem
```


### What is the difference between signing a certificate and encrypting?

They are related in that they use the same encryption algorithm e.g: RS256. 

However they serve different purposes.

**Signing**: Used to maintain integrity and authenticity when the CA signs a certificate or an OIDC server signs a token.  The data is hashed and then signed by the server's private key. The client or relying party uses the public key to expose the hashed data by decrypting the signature or message. When we refer to "signing", we generally mean to use a private key to sign a piece of data that can be extracted via the public key.


**Encryption**: Use to maintain confidentiality where the client encrypts the data using the server's public key (available to the client) that is then decrypted by the server's private key. 

### What is a Self Signed Certificate?

A self-signed certificate is a digital certificate that is signed by the same entity whose identity it certifies. In other words, the issuer and the subject of the certificate are the same. Self-signed certificates are typically used for testing, development, or internal purposes where trust can be established without relying on a third-party Certificate Authority (CA).

It is worth noting that self-signed certificates do not provide the same level of trust as certificates issued by a trusted CA, as they are not validated by an external authority. As a result, web browsers and other clients may display warnings when encountering self-signed certificates, indicating that the connection may not be secure.

