# RBAC: identity in Kubernetes

**Pillars:** 🪪 Identity

## Why this matters

**RBAC** (role-based access control) is how Kubernetes decides who can do what. It's the same model as AWS IAM from [Module 7](../../07-identity/), with different names, and the same mistakes show up in real clusters: wildcard permissions, "just give them cluster-admin," and roles nobody remembers creating.

## Module 7 → Kubernetes

| AWS IAM | Kubernetes RBAC | Notes |
|---|---|---|
| A policy | A **Role** (one namespace) or **ClusterRole** (whole cluster) | A list of rules: API groups, resources, verbs |
| Attaching a policy | A **RoleBinding** or **ClusterRoleBinding** | Connects a role to a subject |
| User, group, role | **User**, **Group**, **ServiceAccount** | Kubernetes doesn't store users; it trusts whatever identity the credential carries |
| Actions (`s3:GetObject`) | **Verbs** (`get`, `list`, `create`, `delete`...) on **resources** (`pods`, `secrets`...) | |
| Implicit deny | Same: nothing is allowed unless a binding allows it | RBAC has **no** deny rules at all |

## Do it

1. **Read the roles.** Open [`rbac.yaml`](manifests/rbac.yaml). The `log-reader` Role allows `get`, `list`, and `watch` on `pods` and `pods/log` in the `logslayer` namespace. The `alice-log-reader` RoleBinding gives it to a user called `alice`. Read it as a sentence, the way you read IAM policies: "Alice may get, list, and watch pods and their logs, in the logslayer namespace only."

2. Apply it:

   ```bash
   cd ~/my-security-portfolio/kubernetes/manifests
   kubectl apply -f rbac.yaml
   ```

3. **Test it without being Alice.** As cluster-admin, you can ask "what could Alice do?" with `--as`, which **impersonates** her for that one command ([Module 7](../../07-identity/07-impersonation.md)):

   ```bash
   kubectl auth can-i list pods -n logslayer --as alice
   kubectl auth can-i get pods/log -n logslayer --as alice
   kubectl auth can-i delete pods -n logslayer --as alice
   kubectl auth can-i list pods -n kube-system --as alice
   kubectl auth can-i get secrets -n logslayer --as alice
   ```

   `yes`, `yes`, `no`, `no`, `no`. Write your predictions first, like the Policy Simulator in [Module 7](../../07-identity/05-evaluation-logic.md).

4. **Act as Alice:**

   ```bash
   kubectl get pods -n logslayer --as alice
   kubectl logs -n logslayer job/logslayer-report --as alice
   ```

   Both work. She can do her job: read the report.

5. **See everything she can do**, in one list:

   ```bash
   kubectl auth can-i --list -n logslayer --as alice
   ```

## Break it

Try what Alice can't do, and read the error:

```bash
kubectl delete pod -n logslayer -l app=web --as alice
```

```
Error from server (Forbidden): pods "web-..." is forbidden: User "alice" cannot delete resource "pods"
in API group "" in the namespace "logslayer"
```

Who, what, which resource, where: the same four parts as an AWS `AccessDenied` ([Module 6](../../06-cloud-aws/07-data.md)).

Now make the mistake people make under pressure. Alice says she can't do something; someone runs:

```bash
kubectl create clusterrolebinding alice-admin --clusterrole=cluster-admin --user=alice
kubectl auth can-i '*' '*' --all-namespaces --as alice
```

`yes`. Alice can now read every secret in every namespace, delete the cluster's own components, and grant herself (or anyone) anything. One command, no review. That binding is the Kubernetes version of `AdministratorAccess` on everything. Delete it right away:

```bash
kubectl delete clusterrolebinding alice-admin
```

And look for any others like it, the query you'd run on any cluster you review:

```bash
kubectl get clusterrolebindings -o json | jq -r '.items[] | select(.roleRef.name == "cluster-admin") | "\(.metadata.name): \(.subjects // [] | map(.kind + "/" + .name) | join(", "))"'
```

On a fresh kind cluster, only the built-in ones should appear.

## With Claude

Ask Claude Code:

```text
Write a Kubernetes Role and RoleBinding for a "deployer" service account in
the logslayer namespace that can update the web Deployment's image, and
nothing else. Then give me kubectl auth can-i commands to prove it.
```

**Check the work:**

- Is it a **Role**, not a ClusterRole? Namespace-scoped, so it can't touch anything else.
- Does it use `resourceNames: ["web"]`, so it can't change other Deployments?
- Verbs: `get` and `patch` (or `update`) on `deployments` in the `apps` group. Did it add `*`, `create`, or `delete`?
- Did it grant `pods/exec`, `secrets`, `escalate`, or `bind`? Each of those is a path to more access.
- Run its `can-i` commands, plus your own "should be no" checks, with `--as system:serviceaccount:logslayer:deployer`.

## Check yourself

1. What's the difference between a Role and a ClusterRole?
   <details><summary>Answer</summary>

   A Role applies in one namespace. A ClusterRole can apply cluster-wide, or be bound in one namespace with a RoleBinding.
   </details>

2. Can Kubernetes RBAC deny something explicitly, like an IAM Deny?
   <details><summary>Answer</summary>

   No. RBAC only allows; everything else is denied by default. Removing access means removing bindings.
   </details>

3. Why is a ClusterRoleBinding to `cluster-admin` so dangerous?
   <details><summary>Answer</summary>

   It grants every action on every resource in every namespace, including reading all secrets and granting more access to anyone.
   </details>

## Go deeper

- [Kubernetes: using RBAC authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [RBAC good practices](https://kubernetes.io/docs/concepts/security/rbac-good-practices/): including the verbs that let someone escalate.
