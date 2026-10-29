# What Kubernetes is

**Pillars:** 🪪 Identity

## Why this matters

One container is easy: `docker run`. A company runs thousands, across many servers, and needs them restarted when they crash, spread out when traffic spikes, and updated without downtime. **Kubernetes** does that. You tell it what you want running ("two copies of this web server"), and it keeps making it true.

That makes Kubernetes powerful, and a big target. Whoever can talk to a cluster's API can usually run anything on it. The security ideas are ones you already know: identity, least privilege, segmentation, and locked-down containers, with new names.

## The objects you need

Kubernetes is driven by **objects** you describe in YAML files. Six cover most of the work:

| Object | What it is | You already know it as |
|---|---|---|
| **Pod** | One or more containers running together; the smallest thing Kubernetes runs | A `docker run` ([Module 5](../../05-containers/02-running-containers.md)) |
| **Deployment** | Keeps a number of identical pods running, and replaces them when they die or when you update | `systemctl enable`, but for many copies ([Module 2](../../02-linux/06-services.md)) |
| **Job** | Runs a pod until it finishes, once | A script you run, like `logslayer` |
| **Service** | A stable name and address in front of a set of pods | DNS plus a load balancer ([Module 4](../../04-networking/04-dns.md)) |
| **Namespace** | A folder for objects, with its own permissions and policies | An AWS account boundary, roughly |
| **ServiceAccount** | An identity for pods | An IAM role ([Module 7](../../07-identity/06-service-accounts.md)) |

Two more you'll meet for security: **Role/RoleBinding** (who can do what, lesson 4) and **NetworkPolicy** (which pods can talk to which, lesson 6).

## Do it

1. **Install the two tools** in your VM. **kind** ("Kubernetes in Docker") runs a whole cluster inside Docker containers, free. **kubectl** is the command you use to talk to any cluster. Both are single files; check each download's hash before installing it ([Module 5](../../05-containers/08-verify-before-you-trust.md)):

   ```bash
   arch=$(dpkg --print-architecture)

   curl -fsSLO "https://github.com/kubernetes-sigs/kind/releases/download/v0.33.0/kind-linux-${arch}"
   curl -fsSLO "https://github.com/kubernetes-sigs/kind/releases/download/v0.33.0/kind-linux-${arch}.sha256sum"
   sha256sum -c "kind-linux-${arch}.sha256sum"
   sudo install -m 755 "kind-linux-${arch}" /usr/local/bin/kind

   K8S=$(curl -fsSL https://dl.k8s.io/release/stable.txt)
   curl -fsSLO "https://dl.k8s.io/release/${K8S}/bin/linux/${arch}/kubectl"
   curl -fsSLO "https://dl.k8s.io/release/${K8S}/bin/linux/${arch}/kubectl.sha256"
   echo "$(cat kubectl.sha256)  kubectl" | sha256sum -c
   sudo install -m 755 kubectl /usr/local/bin/kubectl

   rm -f kind-linux-* kubectl kubectl.sha256
   kind version
   kubectl version --client
   ```

   Both `sha256sum` checks must say `OK` before you install.

   > **Last verified:** 2026-10-29 with kind v0.33.0 and Kubernetes v1.37 ([kind](https://kind.sigs.k8s.io/), [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)).

2. **Read a manifest before you create one.** Every object in Kubernetes is described the same way. Look at the [web server](manifests/web.yaml) you'll deploy in lesson 3:

   ```yaml
   apiVersion: apps/v1         # which version of the API this object uses
   kind: Deployment            # what kind of object
   metadata:
     name: web                 # its name
     namespace: logslayer      # which namespace it lives in
   spec:                       # what you want: the desired state
     replicas: 2
     ...
   ```

   Every manifest has those four top-level parts. `spec` is the part you'll spend your time on.

3. **Write down the security model in your own words**, in your portfolio as `kubernetes/notes.md`. For each object in the table above, one line on what an attacker could do with it if they controlled it. (A Deployment: run their own code, forever, as many copies as they want.)

## Break it

There's no cluster yet to break, so break the idea. A friend says: "Kubernetes is secure by default, it's what big companies use."

List five things a default cluster **doesn't** do for you that you've learned to care about. Answer in `notes.md`, then check your list against lessons 4 to 7 when you get there.

<details><summary>Some answers</summary>

By default, pods can talk to every other pod (no segmentation), containers can run as root, pods get an API token mounted whether they need it or not, and the cluster admin's credentials sit in a file on whoever set it up. Images can come from anywhere, unpinned. Each one is a lesson in this track.
</details>

## With Claude

Ask Claude Code:

```text
Explain the difference between a Pod, a Deployment, and a Job in Kubernetes,
using examples from my own course work: logslayer (a CLI tool) and a web server.
```

**Check the work:** a good answer says `logslayer` should be a **Job** (it runs and finishes) and the web server a **Deployment** (it should keep running). If Claude suggests running `logslayer` as a Deployment, think about what would happen: it finishes in a second, Kubernetes thinks it crashed, and restarts it forever. That's a real, common beginner mistake, and a sign the answer wasn't about **your** tool.

## Check yourself

1. Which object keeps two copies of a web server running?
   <details><summary>Answer</summary>

   A Deployment.
   </details>

2. What's a ServiceAccount, in AWS terms?
   <details><summary>Answer</summary>

   An identity for pods, like an IAM role for a service.
   </details>

3. Why check the hash of the `kind` and `kubectl` downloads?
   <details><summary>Answer</summary>

   To prove the file is exactly what the project published, not something tampered with on the way.
   </details>

## Go deeper

- [Kubernetes concepts: overview](https://kubernetes.io/docs/concepts/overview/): the official introduction.
