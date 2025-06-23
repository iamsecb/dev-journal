---
tags:
  - k8s
  - cillium
  - network-policy
---

# Cilium 

## Cilium Network Policy

Oh man trying to deal with Cillium network policies can be painful when the cluster automatically enforces usage of it and you are trying to figure out 
how to make it work. 

So turns out the cluster has  a `allow-dns` network policy but I was facing dns lookup errors.

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: aws-load-balancer-controller  
spec:
  egress:
  - ports:
    - port: 53
      protocol: UDP
    - port: 53
      protocol: TCP
    to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
  podSelector: {}
  policyTypes:
  - Egress
  ```

This looks like it should work except that the `kube-system` namespace does not have that label.


```
k get ns kube-system -o yaml | yq .metadata.labels
kubernetes.io/metadata.name: kube-system
```

To prove this further:

```
k run -it dns-test-pod --image=busybox:1.36.1 --restart=Never --rm --namespace=vault-test -- sh -c "nslookup kubernetes.default.svc.cluster.local"
If you don't see a command prompt, try pressing enter.
;; connection timed out; no servers could be reached

pod "dns-test-pod" deleted
pod vault-test/dns-test-pod terminated (Error)
```


After adding the correct label:

```
k run -it dns-test-pod --image=busybox:1.36.1 --restart=Never --rm --namespace=vault-test -- sh -c "nslookup kubernetes.default.svc.cluster.local"
Server:		198.19.0.10
Address:	198.19.0.10:53


Name:	kubernetes.default.svc.cluster.local
Address: 198.19.0.1

pod "dns-test-pod" deleted
```

In the end I have used this cillium network policy:


```
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: aws-load-balancer-controller-access
  namespace: aws-load-balancer-controller
spec:
  endpointSelector:
    matchLabels: {} # all pods in aws-load-balancer-controller namespace
  egress:
  # Could use is but I'm using the toEndpoints option to target all Pods in kube-system namespace
  # - toEntities:
  #   - kube-apiserver
  - toFQDNs:
    - matchPattern: "*.amazonaws.com"
  - toCIDR:
    - 169.254.169.254/32  # IMDS endpoint
  - toEndpoints:
    - matchLabels:
        kubernetes.io/metadata.name: kube-system # Allow access to api server, dns server etc.
  - toPorts:
    # DNS workaround
    - ports:
        - port: "53"
          protocol: ANY
      rules:
        dns:
          - matchPattern: "*"
    - ports:
        - port: "443"
          protocol: TCP
  ingress:
  - fromEntities:
    - kube-apiserver # This built-in entity refers to the Kubernetes API server
```


