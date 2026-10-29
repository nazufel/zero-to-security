# Your first cluster

**Pillars:** 🪪 Identity

## Why this matters

The first thing to learn about any cluster is how you're connected to it, and who that connection says you are. The file that connects `kubectl` to a cluster, the **kubeconfig**, is a credential. In most setups, including the one you're about to make, it's the credential of the cluster's **administrator**. A stolen kubeconfig is a stolen cluster.

## Do it

1. **Create a cluster.** kind uses Docker, and Docker needs `sudo` in this course ([Module 5](../../05-containers/01-why-containers.md)):

   ```bash
   sudo kind create cluster --name lab
   ```

   It takes a minute or two. kind starts a Docker container that **is** a Kubernetes node, with everything a cluster needs inside it:

   ```bash
   sudo docker ps --filter name=lab
   ```

2. **Connect `kubectl` as yourself.** kind saved the connection details in root's home folder. Copy them to yours, and lock the file down:

   ```bash
   mkdir -p ~/.kube
   sudo kind get kubeconfig --name lab > ~/.kube/config
   chmod 600 ~/.kube/config
   kubectl cluster-info
   ```

   `kubectl` doesn't need Docker or `sudo`: it talks to the cluster's API server over HTTPS, using the credentials in that file.

3. **Look around:**

   ```bash
   kubectl get nodes
   kubectl get namespaces
   kubectl get pods --all-namespaces
   ```

   One node, a few built-in namespaces, and the system pods that run the cluster itself in `kube-system`: the API server, the scheduler, DNS, and the network plugin.

4. **Find out who you are.** Same question as [Module 7](../../07-identity/01-identity-101.md), new system:

   ```bash
   kubectl auth whoami
   kubectl auth can-i '*' '*' --all-namespaces
   ```

   ```
   ATTRIBUTE   VALUE
   Username    kubernetes-admin
   Groups      [kubeadm:cluster-admins system:authenticated]
   yes
   ```

   You can do **everything**, everywhere. That's fine for a lab you own. Remember it.

5. **Create the namespace you'll use for the rest of the track.** Copy this track's [manifests](manifests/) into your portfolio first:

   ```bash
   mkdir -p ~/my-security-portfolio/kubernetes/manifests && cd ~/my-security-portfolio/kubernetes/manifests
   for f in namespace job web toolbox rbac netpol; do
     curl -fsSLO "https://raw.githubusercontent.com/nazufel/zero-to-security/main/dig-deeper/kubernetes/manifests/$f.yaml"
   done
   kubectl apply -f namespace.yaml
   kubectl get namespace logslayer --show-labels
   ```

   Look at its labels: `pod-security.kubernetes.io/enforce=restricted`. That turns on a guardrail you'll test in lesson 7.

## Break it

Look at the credential:

```bash
grep -c "client-key-data" ~/.kube/config
ls -l ~/.kube/config
```

The file holds a client certificate **and its private key**. Anyone who copies it is `kubernetes-admin` for as long as the certificate is valid, which for kind is a year. There's no MFA, no session that expires in an hour, and no "who" beyond a name in a certificate.

Compare it with your AWS setup: `aws login` gives short-lived sessions, and Claude gets its own view-only role. Write in `notes.md` what you'd want instead at work. (Real clusters connect `kubectl` to the company's single sign-on, so people log in as **themselves** with short-lived tokens, and the admin certificate is locked away like the AWS root user.)

And if you run Claude Code in this VM: add `"Read(~/.kube/**)"` and `"Bash(kubectl *)"` to your managed-settings deny list ([Module 8](../../08-security-concepts/12-ai-in-a-box.md)), the same way you denied `aws`. A cluster-admin kubeconfig is as dangerous as your AWS session.

## With Claude

Ask Claude Code:

```text
I'm running a kind cluster for learning. What are the security risks of the
kubeconfig file kind creates, and how do real companies handle kubectl access
instead? Don't read my kubeconfig.
```

**Check the work:** did it respect "don't read my kubeconfig"? (If your deny rule is in place, it couldn't.) A good answer covers: the file is cluster-admin, certificates can't easily be revoked, and companies use OIDC or cloud identity (like EKS with IAM) for short-lived, per-person access. Check any specific product it names actually does what it says.

## Check yourself

1. What's in a kubeconfig, and why is it sensitive?
   <details><summary>Answer</summary>

   The cluster's address and a credential, here a client certificate and private key for the cluster admin. Whoever has it can do anything in the cluster.
   </details>

2. What does `kubectl auth can-i '*' '*'` answer?
   <details><summary>Answer</summary>

   Whether you're allowed to do every action on every resource. "Yes" means you're effectively cluster-admin.
   </details>

3. Why doesn't `kubectl` need `sudo` when `kind` does?
   <details><summary>Answer</summary>

   `kind` controls Docker, which needs root. `kubectl` only talks to the cluster's API over HTTPS, using the credentials in your kubeconfig.
   </details>

## Go deeper

- [kind quick start](https://kind.sigs.k8s.io/docs/user/quick-start/): multi-node clusters and other options.
