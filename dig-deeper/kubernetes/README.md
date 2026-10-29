# Dig Deeper: Kubernetes

**Pillars:** 🪪 Identity · 🤖 AI

> 🚧 **Outline.** Optional track. Do the [Containers module](../../05-containers/) first.

## Why this matters

Kubernetes runs containers at scale, and it's on a lot of job postings. It's also a big topic, and the real thing in AWS (EKS) bills by the hour. So we run it locally for free, and focus on the security ideas you already know: identity, least privilege, and segmentation.

## Opinions

- **[kind](https://kind.sigs.k8s.io/)** (Kubernetes in Docker) inside your Ubuntu VM. Free, and it reuses your Docker setup.
- **Your own `logslayer` image** as the workload, so nothing is new except Kubernetes itself.

## Ready to put it on your resume when…

- [ ] You can create a kind cluster and deploy your image with a Deployment and a Service
- [ ] You can use `kubectl` to list, describe, read logs from, and delete resources
- [ ] You can explain who can do what in the cluster with RBAC, and write a Role and RoleBinding
- [ ] You can give a pod its own service account with only the permissions it needs
- [ ] You can write a network policy that blocks traffic between pods
- [ ] You can lock a pod down: non-root, read-only filesystem, no privilege escalation
- [ ] You can review a Claude-written manifest for privilege escalation risks

## Lessons (planned)

1. **What Kubernetes is**, and the five objects you need: Pod, Deployment, Service, Namespace, ServiceAccount
2. **Your first cluster** with kind
3. **Deploy `logslayer`**
4. **RBAC:** identity in Kubernetes. *Break it:* try an action your service account isn't allowed to do.
5. **Service accounts:** the Kubernetes version of IAM roles
6. **Network policies:** segmentation inside the cluster
7. **Pod security:** non-root and friends, which your Chainguard image already gets right
8. **With Claude:** Claude writes the manifests; you hunt for privilege escalation

## Go deeper

- [Kubernetes docs: tutorials](https://kubernetes.io/docs/tutorials/)
- [Kubernetes Goat](https://madhuakula.com/kubernetes-goat/): an intentionally vulnerable cluster for practice
