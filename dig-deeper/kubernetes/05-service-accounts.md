# Service accounts

**Pillars:** 🪪 Identity

## Why this matters

Every pod runs as a **ServiceAccount**, the Kubernetes version of an IAM role for a service ([Module 7](../../07-identity/06-service-accounts.md)). Unless you say otherwise, Kubernetes mounts that account's API token into the pod, as a file. An attacker who gets a shell in any pod checks that file first. If the account has broad permissions, one compromised web server becomes a compromised cluster.

## Do it

1. **See the default.** Run a test pod **without** turning off the token, and look inside:

   ```bash
   kubectl run peek -n logslayer --image=cgr.dev/chainguard/wolfi-base:latest --restart=Never \
     --overrides='{"spec":{"securityContext":{"runAsNonRoot":true,"runAsUser":65532,"seccompProfile":{"type":"RuntimeDefault"}},"containers":[{"name":"peek","image":"cgr.dev/chainguard/wolfi-base:latest","command":["sleep","3600"],"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}}]}}'
   kubectl wait -n logslayer --for=condition=Ready pod/peek
   kubectl exec -n logslayer peek -- ls /var/run/secrets/kubernetes.io/serviceaccount/
   ```

   ```
   ca.crt
   namespace
   token
   ```

   A token for the namespace's `default` service account, sitting in every pod that didn't opt out. (The long `--overrides` is to satisfy the namespace's security rules, which you'll meet in lesson 7.)

2. **What can that token do?**

   ```bash
   kubectl auth can-i --list -n logslayer --as system:serviceaccount:logslayer:default
   ```

   Very little, by default: some discovery, nothing in the namespace. The danger isn't the default; it's what people **add** to it later ("the app needs to read a ConfigMap, give the default account a role"), because then every pod in the namespace gets it.

3. **Do it right: one account per workload, token only if needed.** Look at [`job.yaml`](manifests/job.yaml): `logslayer` has its own ServiceAccount with `automountServiceAccountToken: false`, because it never talks to the Kubernetes API. Check:

   ```bash
   kubectl get pod -n logslayer -l app=logslayer -o jsonpath='{.items[0].spec.automountServiceAccountToken}{"\n"}'
   ```

   `false`. Nothing to steal.

4. **A workload that does need the API.** The `reporter` account in [`rbac.yaml`](manifests/rbac.yaml) can `get` exactly one ConfigMap, `auth-log`, by name. Prove the boundary:

   ```bash
   SA=system:serviceaccount:logslayer:reporter
   kubectl auth can-i get configmap/auth-log -n logslayer --as $SA
   kubectl auth can-i get configmap/other -n logslayer --as $SA
   kubectl auth can-i list configmaps -n logslayer --as $SA
   kubectl auth can-i get secrets -n logslayer --as $SA
   ```

   `yes`, `no`, `no`, `no`. `resourceNames` is the Kubernetes version of a specific resource ARN instead of `*`.

5. Clean up: `kubectl delete pod -n logslayer peek`.

## Break it

Make the mistake that turns one pod into the whole cluster. Give the namespace's **default** account cluster-admin, "so the app works":

```bash
kubectl create clusterrolebinding default-admin --clusterrole=cluster-admin --serviceaccount=logslayer:default
```

Recreate `peek` from step 1. Now, from **inside** the pod, its token is cluster-admin. Prove it with `can-i`:

```bash
kubectl auth can-i '*' '*' --all-namespaces --as system:serviceaccount:logslayer:default
```

`yes`. Any pod in that namespace, including a web server with a bug in it, now carries a token that can read every secret and run anything on every node. Attackers who find this in a real cluster don't need any other exploit. Delete the binding, and `peek`:

```bash
kubectl delete clusterrolebinding default-admin
kubectl delete pod -n logslayer peek
```

## With Claude

Ask Claude Code:

```text
Compare Kubernetes ServiceAccounts with AWS IAM roles. How do pods get
credentials, how long do they last, and what's the equivalent of an
instance profile? Then tell me how EKS connects ServiceAccounts to IAM roles.
```

**Check the work:** a good answer mentions that modern Kubernetes mounts **short-lived, auto-rotated** tokens (bound service account tokens), not permanent ones, and that EKS links a ServiceAccount to an IAM role (IRSA, or EKS Pod Identity), so pods get temporary AWS credentials with no keys. Check those names against the [EKS docs](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html). If it says tokens never expire, it's describing old Kubernetes.

## Check yourself

1. Where does a pod's service account token live?
   <details><summary>Answer</summary>

   Mounted as a file at `/var/run/secrets/kubernetes.io/serviceaccount/token`, unless automounting is turned off.
   </details>

2. Why give each workload its own ServiceAccount?
   <details><summary>Answer</summary>

   Least privilege. Permissions granted to a shared or default account reach every pod that uses it.
   </details>

3. A pod never calls the Kubernetes API. What should its spec say?
   <details><summary>Answer</summary>

   `automountServiceAccountToken: false`, so there's no token to steal.
   </details>

## Go deeper

- [Kubernetes: service accounts](https://kubernetes.io/docs/concepts/security/service-accounts/)
