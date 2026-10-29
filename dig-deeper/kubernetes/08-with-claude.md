# With Claude: hunting privilege escalation

**Pillars:** 🤖 AI · 🪪 Identity

## Why this matters

AI writes a lot of Kubernetes YAML now, because there's so much of it. It's also very good at producing manifests that **work** by quietly giving away the farm: a ClusterRoleBinding to cluster-admin, a privileged container "for debugging," a host mount "to read logs." The YAML applies, the app runs, and nobody notices until someone does.

Reviewing a manifest for privilege escalation is a real, hireable skill. This lesson trains it on Claude's output, with a scanner to back you up.

## The checklist

Every manifest Claude writes gets checked against this, by you, before it's applied:

| Look for | Why it's dangerous |
|---|---|
| `privileged: true`, `hostPID`, `hostNetwork`, `hostIPC` | The container can reach the node itself |
| `hostPath` volumes | The node's files, inside the container |
| `runAsUser: 0`, no `runAsNonRoot` | Root in the container |
| `allowPrivilegeEscalation` not `false`, capabilities not dropped | Room to gain more privilege |
| `ClusterRoleBinding`, `cluster-admin`, `*` in verbs or resources | Far more access than one app needs |
| RBAC verbs `escalate`, `bind`, `impersonate`, or `create` on `pods/exec` | Ways to grant yourself more |
| `automountServiceAccountToken` not `false` | A token to steal, when the app doesn't need one |
| Images by tag, or a short name like `myapp:latest` | Unpinned, possibly pulled from Docker Hub |
| No network policy | A flat network |

## Do it

1. **Scan what you have**, with Checkov, the same scanner you used for OpenTofu in [Module 8](../../08-security-concepts/14-scanning-infrastructure-code.md):

   ```bash
   cd ~/my-security-portfolio/kubernetes/manifests
   uvx checkov@3.4.0 --directory . --framework kubernetes --compact --quiet
   ```

   Your manifests pass most checks. What's left: images not pinned by digest, no health probes on the web server, and no read-only filesystem on nginx and the toolbox. Fix the digests now: look them up the way you did in [Module 5](../../05-containers/07-pin-by-digest.md), and change `cgr.dev/chainguard/nginx:latest` to `cgr.dev/chainguard/nginx:latest@sha256:...`. Record the others as accepted, with reasons, in `kubernetes/notes.md`.

2. **Have Claude write a workload**, with no security guidance at all, the way most people ask:

   ```text
   Write Kubernetes manifests for a log collector that runs on every node
   (a DaemonSet), reads the node's /var/log, and can list pods in all
   namespaces so it can label logs with pod names. Put it in a namespace
   called collector.
   ```

3. **Review it against the checklist**, line by line, **before** applying anything. A log collector genuinely needs some access to the node, which makes this a realistic test: some of the risky settings are needed, and your job is to keep only those, as narrowly as possible. For example:

   - Reading `/var/log` needs a `hostPath`, but it should be `readOnly: true`, and only `/var/log`, not `/`.
   - Listing pods in all namespaces needs a ClusterRole, but only `get`, `list`, and `watch` on `pods`. Not `cluster-admin`, not `*`.
   - It doesn't need `privileged`, root, or a writable host mount.

   Write every finding in `kubernetes/review.md`: the line, the risk, and your fix.

4. **Scan Claude's version**, then yours:

   ```bash
   uvx checkov@3.4.0 --file claude-collector.yaml --framework kubernetes --compact --quiet
   uvx checkov@3.4.0 --file my-collector.yaml --framework kubernetes --compact --quiet
   ```

   Compare. Did the scanner catch everything you did? Did you catch things it didn't, like a ClusterRole that's broader than the job? Scanners know patterns. Reviewers know **intent**.

5. **Apply only your fixed version**, in a namespace with Pod Security enforcement. Note the level you can get to: a node log collector won't meet "restricted" (it needs a host path), so its namespace needs "baseline," and that exception goes in your notes with a reason.

## Break it

Ask Claude for something that sounds harmless:

```text
My pod can't read secrets in another namespace. Fix it.
```

See what it suggests, and whether it asks **why** the pod needs another namespace's secrets at all. The most dangerous answer is a ClusterRoleBinding that lets the pod read **every** secret in the cluster. The best answer questions the request: cross-namespace secret access is usually a design problem, not a permissions problem. Write what Claude did in `review.md`. An AI that makes errors go away is not the same as an AI that makes systems safe.

## With Claude

Close the loop. Give Claude your checklist and your fixed collector, and ask it to attack the result:

```text
Here's my security review checklist and my log collector manifests. Assume
an attacker has code execution inside the collector container. What can
they reach, and what's the next step they'd try? Don't apply anything.
```

**Check the work:** its answer should be limited by what you locked down: read-only node logs (which can still contain secrets, a real risk), listing pod names cluster-wide (information for the attacker's map), and nothing to write or escalate with. If it describes an escape that your settings block, ask it which line allows it. If none does, it's wrong. If one does, you found a gap: fix it.

## Check yourself

1. Name three manifest settings that let a container reach the node.
   <details><summary>Answer</summary>

   Any three of: `privileged: true`, `hostPID`, `hostNetwork`, `hostIPC`, and `hostPath` volumes.
   </details>

2. A log collector needs to read `/var/log` on each node. How do you allow that safely?
   <details><summary>Answer</summary>

   A `hostPath` of `/var/log` only, mounted `readOnly: true`, with the container still non-root, unprivileged, and with capabilities dropped.
   </details>

3. Why isn't a clean scanner result enough?
   <details><summary>Answer</summary>

   Scanners match known patterns. They can't tell whether a permission is broader than the workload's actual job; a reviewer who knows the intent can.
   </details>

## Go deeper

- [Kubernetes Goat](https://madhuakula.com/kubernetes-goat/): an intentionally vulnerable cluster, to practice attacking and defending. Run it in kind, in your VM, only.
- [OWASP Kubernetes Top 10](https://owasp.org/www-project-kubernetes-top-ten/)
