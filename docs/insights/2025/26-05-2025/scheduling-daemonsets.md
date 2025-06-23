---
tags:
  - k8s
  - daemonsets
---

# Scheduling DaemonSets

Today I had to install the aws-efs-csi-driver and I was faced with the decision of which namespace it should belong to and if I should be adding tolerations to 
place it onto certain nodes or all nodes. 

The default values.yaml file in the helm chart had:

```
  nodeSelector: {}
  tolerations:
    - operator: Exists
```

To make sense of this:


> DaemonSets work with taints and tolerations as follows: If a node has a taint, only Pods that tolerate that taint can be scheduled onto it. By default, DaemonSet Pods are not scheduled on tainted nodes (such as control plane nodes) unless you explicitly add tolerations to the Pod template in the DaemonSet. For example, the kube-proxy DaemonSet uses a toleration with `operator: Exists`, which allows its Pods to tolerate all taints and thus be scheduled on all nodes, including those with taints. You add tolerations in the spec.template.spec.tolerations field of the DaemonSet manifest. This is necessary if you want your DaemonSet Pods to run on nodes with special taints, such as control plane node.

So the default which I assume are sensible defaults expect the DaemonSet Pods to run on all nodes.

But then I also see nodeSelector and affinitiy options. Now the way I understand it is that Taints and Tolerations are to determine if a Pod can be scheduled onto a Node, NodeSelector is for a preferred node but Affinitiy was unclear to me.


```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: example-daemon
spec:
  selector:
    matchLabels:
      app: example-daemon
  template:
    metadata:
      labels:
        app: example-daemon
    spec:
      # Tolerations: allow scheduling on tainted nodes (e.g., control-plane)
      tolerations:
      - operator: Exists
      # NodeSelector: restrict to nodes with a specific label
      nodeSelector:
        gpu: cuda
      # Affinity: (added by DaemonSet controller) ensures each Pod is scheduled to a specific node
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchFields:
              - key: metadata.name
                operator: In
                values:
                - kind-worker
      containers:
      - name: example
        image: busybox
        command: ["sleep", "infinity"]
```        

What this means is:


| Feature                    | Type                 | Scheduling Effect                        |
| -------------------------- | -------------------- | ---------------------------------------- |
| `nodeSelector`             | 🔒 Hard Requirement  | Pod **must** match specified node labels |
| `nodeAffinity` (required)  | 🔒 Hard Requirement  | Like `nodeSelector`, but more flexible because you can have OR conditions   |
| `nodeAffinity` (preferred) | 🎯 Soft Preference   | Try to match, but not required           |
| `taints` + `tolerations`   | 🔐 Permission System | Node **repels** pods unless tolerated    |


In other words you can achieve the same thing as `NodeSelector` with `Affinity`. However, `NodeSelector` is more simple and direct unless you want to match
multiple labels, then you need `Affinity`.


A side on on Affinity's `nodeAffinitiy.requiredDuringSchedulingIgnoredDuringExecution`

It has two parts:

1. `requiredDuringScheduling`:
This means the condition must be met at the time the Pod is scheduled. If no matching node is found, the Pod will not be scheduled at all — just like a nodeSelector.

2. `IgnoredDuringExecution`:
This means once the Pod is running, Kubernetes won’t evict it even if the node’s labels change and no longer match the rule.