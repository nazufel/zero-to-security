# Kubernetes quiz

Answer each question out loud or on paper *before* you open the answer.

1. `logslayer` runs and exits in a second. Deployment or Job, and what happens if you pick wrong?
   <details><summary>Answer</summary>

   A Job. As a Deployment, Kubernetes would treat every exit as a crash and restart it forever.
   </details>

2. Someone copies your `~/.kube/config` from a kind cluster. What can they do?
   <details><summary>Answer</summary>

   Everything: it holds the cluster-admin certificate and key, valid for a long time, with no MFA.
   </details>

3. Read this rule as a sentence: `apiGroups: [""], resources: ["configmaps"], resourceNames: ["auth-log"], verbs: ["get"]`.
   <details><summary>Answer</summary>

   Allow reading the one ConfigMap named `auth-log`, in this Role's namespace, and nothing else.
   </details>

4. How do you check what a service account could do, without running a pod as it?
   <details><summary>Answer</summary>

   `kubectl auth can-i <verb> <resource> -n <ns> --as system:serviceaccount:<ns>:<name>`, or `--list` for everything.
   </details>

5. A pod never calls the Kubernetes API. What one line should its spec have?
   <details><summary>Answer</summary>

   `automountServiceAccountToken: false`.
   </details>

6. You apply a default-deny NetworkPolicy, but pods can still reach each other. What's the first thing to check?
   <details><summary>Answer</summary>

   Whether the cluster's network plugin enforces network policies at all. Some silently ignore them.
   </details>

7. A network policy allows traffic from pods labeled `role: client`. Who can get around it?
   <details><summary>Answer</summary>

   Anyone who can create or relabel pods in that namespace. RBAC must limit that too.
   </details>

8. Name four settings in a pod spec that would let it escape to the node.
   <details><summary>Answer</summary>

   Any four of: `privileged: true`, `hostPID`, `hostNetwork`, `hostIPC`, a `hostPath` volume (especially `/`), running as root with capabilities.
   </details>

9. What does `pod-security.kubernetes.io/enforce: restricted` on a namespace do?
   <details><summary>Answer</summary>

   Pod Security Admission rejects any pod in that namespace that doesn't meet the restricted standard, before it runs.
   </details>

10. Claude's manifest includes a ClusterRoleBinding to `cluster-admin` "so the collector can read pod names." What do you replace it with?
    <details><summary>Answer</summary>

    A ClusterRole allowing only `get`, `list`, and `watch` on `pods`, bound to the collector's own service account.
    </details>

## Challenge

Play [Kubernetes Goat](https://madhuakula.com/kubernetes-goat/) in a kind cluster in your VM. For each scenario, write which lesson's control would have stopped it.
