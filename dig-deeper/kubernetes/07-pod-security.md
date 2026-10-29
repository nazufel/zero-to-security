# Pod security

**Pillars:** 🪪 Identity

## Why this matters

A container that runs as root, with extra Linux privileges, or with the host's filesystem mounted, isn't much of a box. Many real Kubernetes compromises go: get into one container, find it's privileged, step out onto the node, and from the node, reach every other pod on it. The pod's `securityContext` decides how strong the box is.

Your Chainguard image already gets most of this right: non-root, no shell, minimal ([Module 5](../../05-containers/05-switch-to-chainguard.md)). This lesson makes the **cluster** enforce it, for every pod, whoever wrote the manifest.

## Do it

1. **Read the locks** in [`job.yaml`](manifests/job.yaml):

   | Setting | Means |
   |---|---|
   | `runAsNonRoot: true`, `runAsUser: 65532` | Refuse to start as root |
   | `allowPrivilegeEscalation: false` | No process can gain more privilege than it started with (no `sudo`, no setuid tricks) |
   | `capabilities: drop: ["ALL"]` | Remove every special Linux privilege a container gets by default |
   | `readOnlyRootFilesystem: true` | Nothing can write to the container's files, so an attacker can't drop tools in |
   | `seccompProfile: RuntimeDefault` | Block dangerous system calls the app never needs |
   | `resources.limits` | Cap CPU and memory, so one pod can't starve the node |

2. **Let the cluster enforce it.** The `logslayer` namespace has a label from lesson 2: `pod-security.kubernetes.io/enforce: restricted`. That turns on **Pod Security Admission**, which rejects any pod that doesn't meet Kubernetes' "restricted" standard, before it ever runs. Your manifests pass, which is why they've been applying cleanly.

3. **Check a running pod's real settings**, not just the manifest:

   ```bash
   kubectl exec -n logslayer toolbox -- id
   kubectl exec -n logslayer toolbox -- sh -c 'grep -E "^Cap(Eff|Prm)" /proc/1/status'
   ```

   `uid=65532`, and capability sets of all zeros. Nothing special.

## Break it

Try to run the kind of pod an attacker dreams of finding: privileged, root, with the node's filesystem mounted. Save as `/tmp/escape.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: escape
  namespace: logslayer
spec:
  hostPID: true
  containers:
    - name: shell
      image: cgr.dev/chainguard/wolfi-base:latest
      command: ["sleep", "infinity"]
      securityContext:
        privileged: true
        runAsUser: 0
      volumeMounts:
        - name: host
          mountPath: /host
  volumes:
    - name: host
      hostPath:
        path: /
```

```bash
kubectl apply -f /tmp/escape.yaml
```

```
Error from server (Forbidden): error when creating "/tmp/escape.yaml": pods "escape" is forbidden:
violates PodSecurity "restricted:latest": host namespaces (hostPID=true), privileged (container "shell"
must not set securityContext.privileged=true), ... hostPath volumes (volume "host"), runAsNonRoot ...
```

Rejected, with a list of every problem. Without that namespace label, it would have run: a root shell with the node's whole filesystem at `/host`, the Kubernetes version of `docker run -v /:/host` from [Module 5, lesson 1](../../05-containers/01-why-containers.md).

See it for yourself in a namespace **without** the guardrail:

```bash
kubectl create namespace unguarded
sed 's/namespace: logslayer/namespace: unguarded/' /tmp/escape.yaml | kubectl apply -f -
kubectl wait -n unguarded --for=condition=Ready pod/escape
kubectl exec -n unguarded escape -- ls /host/etc/kubernetes
kubectl delete namespace unguarded
rm /tmp/escape.yaml
```

The node's Kubernetes configuration, from inside a pod. Any namespace without Pod Security enforcement is one bad manifest away from that.

## With Claude

Ask Claude Code:

```text
web.yaml runs Chainguard nginx. Add readOnlyRootFilesystem: true to it
without breaking nginx. Find out which directories nginx needs to write to,
and give it writable emptyDir volumes for just those.
```

**Check the work:** apply it and check the pods reach `Running` and serve the page (`kubectl logs` will tell you if nginx can't write somewhere). Did Claude **check** which paths the Chainguard image writes to, or guess the paths a standard nginx image uses? They can differ, and a guess shows up as a crash loop. Did it keep every other lock in place?

## Check yourself

1. What does Pod Security Admission's "restricted" level do?
   <details><summary>Answer</summary>

   Rejects pods in that namespace that don't meet a locked-down standard: non-root, no privilege escalation, all capabilities dropped, a seccomp profile, and no host access.
   </details>

2. Why is `privileged: true` with a `hostPath` of `/` so dangerous?
   <details><summary>Answer</summary>

   The container runs with nearly full access to the node, and the node's whole filesystem is mounted inside it. That's an escape from the container to the node.
   </details>

3. Why does `readOnlyRootFilesystem` help?
   <details><summary>Answer</summary>

   An attacker in the container can't write files: no downloaded tools, no modified binaries, no persistence in the image's filesystem.
   </details>

## Go deeper

- [Kubernetes: Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
