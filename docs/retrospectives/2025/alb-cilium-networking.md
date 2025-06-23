---
tags:
  - cilium
---

# ALB and Cilium

Applied the AWS LB controller Ingress in the hope that it will just work but I turns out while the TargetGroup healthcheck to the control plane nodes was successful, the healthchecks were failing on the worker nodes. The existing Cilium network policy allowed access from/to k8s API server only.

Ok if I try to think through this, the first question I need to ask is what is different about the control plane nodes vs worker nodes?






