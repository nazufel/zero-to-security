# Dig Deeper: Kubernetes

**Pillars:** 🪪 Identity · 🤖 AI

> **Optional track.** Do the [Containers module](../../05-containers/) first, and ideally [Identity](../../07-identity/) too: this track reuses both.

## Why this matters

Kubernetes runs containers at scale, and it's on a lot of job postings. It's also a big topic, and the real thing in AWS (EKS) bills by the hour. So we run it locally for free, and focus on the security ideas you already know: identity, least privilege, and segmentation.

## Opinions

- **[kind](https://kind.sigs.k8s.io/)** (Kubernetes in Docker) inside your Ubuntu VM. Free, and it reuses your Docker setup.
- **Your own `logslayer` image** as the workload, run as a Job (it's a batch tool), next to a Chainguard nginx web server as a Deployment and Service.
- **Every namespace enforces Pod Security** at the "restricted" level unless there's a written reason it can't.

## Ready to put it on your resume when…

- [ ] You can create a kind cluster, run `logslayer` as a Job, and run a web server with a Deployment and a Service
- [ ] You can use `kubectl` to list, describe, read logs from, and delete resources
- [ ] You can explain who can do what in the cluster with RBAC, and write a Role and RoleBinding
- [ ] You can give a pod its own service account with only the permissions it needs
- [ ] You can write a network policy that blocks traffic between pods
- [ ] You can lock a pod down: non-root, read-only filesystem, no privilege escalation
- [ ] You can review a Claude-written manifest for privilege escalation risks

Then list it [honestly](../../10-capstone-and-hired/07-listing-dig-deeper-honestly.md): "hands-on lab experience with Kubernetes (kind)."

## Lessons

1. [What Kubernetes is](01-what-kubernetes-is.md), the objects you need, and installing kind and kubectl
2. [Your first cluster](02-first-cluster.md), and why the kubeconfig is a cluster-admin credential
3. [Deploy logslayer](03-deploy-logslayer.md) as a Job, and a web server as a Deployment and Service
4. [RBAC](04-rbac.md): identity in Kubernetes. *Break it:* try an action you aren't allowed to do, then see what one bad binding gives away.
5. [Service accounts](05-service-accounts.md): the Kubernetes version of IAM roles
6. [Network policies](06-network-policies.md): segmentation inside the cluster
7. [Pod security](07-pod-security.md): non-root and friends, enforced by the cluster
8. [With Claude](08-with-claude.md): Claude writes the manifests; you hunt for privilege escalation

The [manifests](manifests/) used in every lesson pass schema checks and Checkov, apart from the findings lesson 8 fixes.

## Practice

- [Quiz](quiz.md)
- [Project: a locked-down namespace](project.md)

## When you're done

```bash
sudo kind delete cluster --name lab
```

## Go deeper

- [Kubernetes docs: tutorials](https://kubernetes.io/docs/tutorials/)
- [Kubernetes Goat](https://madhuakula.com/kubernetes-goat/): an intentionally vulnerable cluster for practice
