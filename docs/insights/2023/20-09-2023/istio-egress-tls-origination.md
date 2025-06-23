---
title: Istio Egress TLS Origination
tags:
  - istio
  - tls
---

## Overview

Illustrate how to configure Istio to handle egress traffic to external services for path based routing setup via a Gateway.

```
Client (HTTPS) LB - SSL offload   --> (HTTP) Istio-ingressgateway  --> (HTTPS) External-service
                                                                   --> (HTTP)  Internal-service
               
```

When the incoming request to Istio is HTTP (rather than HTTPS), Istio does not automatically upgrade the request to HTTPS when connecting to the external service. This is also briefly mentioned in the documentation [here](https://istio.io/latest/docs/tasks/traffic-management/egress/egress-tls-origination):

> TLS origination occurs when an Istio proxy (sidecar or egress gateway) is configured to accept unencrypted internal HTTP connections, encrypt the requests, and then forward them to HTTPS servers that are secured using simple or mutual TLS.


### ServiceEntry

Setup a ServiceEntry to enable access to n S3 bucket. The S3 bucket in this instance is our external service.
This is a common configuration for accessing external services from Istio.

!!! info
    The S3 bucket in this example has been configured to serve requests on paths `/.well-known/openid-configuration` and `/oauth/discovery/keys`.



```
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: s3
  namespace: istio-system
spec:
  hosts:
    - samplebucket1234.s3.ap-southeast-2.amazonaws.com
  location: MESH_EXTERNAL
  exportTo:
  - "."
  ports:
    - number: 443
      name: https
      protocol: HTTPS
  resolution: DNS
```

### Gateway

Setup a Gateway that accepts HTTP traffic. It is SSL offloaded at the LB. 

```
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: example-gateway
spec:
  selector:
    istio: ingressgateway  # use Istio default gateway implementation
  servers:
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
        - example.com
```

### VirtualService

In this example, the root path `/` requests should route to the `welcome` internal service  and `/.well-known/openid-configuration` and `/oauth/discovery/keys` to the external service. To provide this traffic routing a VirtualService is configured as shown below.

```
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: s3
spec:
  gateways:
  - example-gateway
  http:
    - match:
        - uri:
            prefix: /
      route:
        - destination:
            host: welcome  # Name of the internal service
            port:
              number: 8080
    - match:
        - uri:
            prefix: /.well-known/openid-configuration 
      route:
        - destination:
            host: samplebucket1234.s3.ap-southeast-2.amazonaws.com
            port:
              number: 443
      headers:
        request:
          set:
            X-Forwarded-Proto: https
            Host: samplebucket1234.s3.ap-southeast-2.amazonaws.com          
    - match:
        - uri:
            prefix: /oauth/discovery/keys
      route:
        - destination:
            host: samplebucket1234.s3.ap-southeast-2.amazonaws.com
            port:
              number: 443
      headers:
        request:
          set:
            X-Forwarded-Proto: https
            Host: samplebucket1234.s3.ap-southeast-2.amazonaws.com          
```

At this point if you try to access the external services i.e: `example.com/.well-known/openid-configuration` or `example.com/oauth/discovery/keys` you will get the following error:

```
upstream connect error or disconnect/reset before headers. reset reason: protocol error
```

This is because the external service is expecting the request to be HTTPS. Istio does not perform TLS origination automatically. This has to be configured explicitly via a DestinationRule.


### DestinationRule

Setup a DestinationRule to perform TLS origination for HTTPS requests on port 443.

```
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: s3
  namespace: istio-system
spec:
  host: samplebucket1234.s3.ap-southeast-2.amazonaws.com
  exportTo:
  - "."
  trafficPolicy:
    portLevelSettings:
    - port:
        number: 443
      tls:
        mode: SIMPLE # initiates HTTPS when accessing samplebucket1234.s3.ap-southeast-2.amazonaws.com
```

The `tls.mode` setting when set to `SIMPLE` will initiate a HTTPS connection to the external service.

### References

-<https://istio.io/latest/docs/tasks/traffic-management/egress/egress-tls-origination/>

