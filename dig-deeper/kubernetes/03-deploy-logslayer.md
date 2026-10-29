# Deploy logslayer

**Pillars:** 🪪 Identity

## Why this matters

Now you'll run your own code on Kubernetes: the hardened `logslayer` image from [Module 5](../../05-containers/project.md), as a **Job**, and a web server as a **Deployment** behind a **Service**. Running real workloads is where you'll see what Kubernetes does for you, and where most of the security decisions in the rest of this track live: in the pod's `spec`.

## Do it

1. **Get your image into the cluster.** The cluster runs inside Docker and can't see your local images by default. Load it in:

   ```bash
   cd ~/my-security-portfolio/logslayer
   sudo docker build -t logslayer:chainguard .
   sudo kind load docker-image logslayer:chainguard --name lab
   ```

2. **Give it a log to read.** A **ConfigMap** holds configuration or small files. Make one from the sample log:

   ```bash
   kubectl create configmap auth-log --namespace logslayer --from-file=auth.log=samples/auth.log
   ```

3. **Run it as a Job.** Read [`job.yaml`](manifests/job.yaml) first. Find the volume that mounts the ConfigMap at `/logs`, **read-only**, the same rule as `-v ...:ro` in [Module 5](../../05-containers/03-ports-and-volumes.md). Then:

   ```bash
   cd ~/my-security-portfolio/kubernetes/manifests
   kubectl apply -f job.yaml
   kubectl get pods -n logslayer --watch
   ```

   The pod goes `ContainerCreating`, then `Completed`. Press `Ctrl+C`, then read its output:

   ```bash
   kubectl logs -n logslayer job/logslayer-report
   ```

   ```
   Failed SSH logins by IP in /logs/auth.log
     203.0.113.7         12
     198.51.100.23        5
     192.0.2.44           3
     10.0.2.2             1
   Skipped 1 line(s) that couldn't be parsed
   ```

   Your tool, from Module 3, in a container from Module 5, on Kubernetes.

4. **Run a web server as a Deployment.** Read [`web.yaml`](manifests/web.yaml): a Deployment with `replicas: 2`, and a Service that sends port 80 to the pods' port 8080. Apply it:

   ```bash
   kubectl apply -f web.yaml
   kubectl get deployment,pods,service -n logslayer
   ```

5. **See it heal itself.** Delete one of the web pods, and watch:

   ```bash
   kubectl delete pod -n logslayer -l app=web --wait=false
   kubectl get pods -n logslayer -l app=web --watch
   ```

   New pods appear straight away. The Deployment's job is to keep two running, so it replaces whatever disappears. `Ctrl+C` when you've seen it.

6. **Reach the Service.** Forward a local port to it:

   ```bash
   kubectl port-forward -n logslayer service/web 8080:80 &
   curl -s localhost:8080 | head -3
   kill %1
   ```

7. Commit your manifests to `~/my-security-portfolio/kubernetes/`.

## Break it

Make the most common first-day error. Change the Job's image tag to one that doesn't exist in the cluster, `logslayer:v2`, and rename the Job so it's new:

```bash
sed 's/logslayer:chainguard/logslayer:v2/; s/name: logslayer-report/name: logslayer-broken/' job.yaml | kubectl apply -f -
kubectl get pods -n logslayer
kubectl describe pod -n logslayer -l job-name=logslayer-broken | tail -8
```

```
STATUS: ErrImagePull  (then ImagePullBackOff)
...
Failed to pull image "logslayer:v2": ... docker.io/library/logslayer:v2: not found
```

Read that last line carefully. Kubernetes didn't just fail to find your image. It went looking for it on **Docker Hub**, as `docker.io/library/logslayer`. If someone published an image with that name there, the cluster would have pulled and run **their** code. That's the supply chain risk from [Module 5](../../05-containers/07-pin-by-digest.md) again: in real clusters, images come from a registry you control, by full name and digest, never a bare short name.

Clean up: `kubectl delete job -n logslayer logslayer-broken`.

## With Claude

Ask Claude Code:

```text
Read job.yaml and web.yaml. Explain what each security-related field in the
pod specs does, and whether any are missing for a production cluster.
```

**Check the work:** each field it explains, check against the [Kubernetes docs](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/). Good "missing" answers: images pinned by digest, health probes on the web server, a read-only root filesystem for nginx. You'll handle those in lessons 7 and 8. If it says something is missing that's already there, it didn't read the file carefully. Log it.

## Check yourself

1. Why is `logslayer` a Job and the web server a Deployment?
   <details><summary>Answer</summary>

   `logslayer` runs and finishes. The web server should keep running, with a set number of copies, replaced if they fail.
   </details>

2. A pod shows `ImagePullBackOff`. Where do you look?
   <details><summary>Answer</summary>

   `kubectl describe pod` and read the events at the bottom. They show which image and registry it tried, and why it failed.
   </details>

3. What does a Service give you that a pod doesn't?
   <details><summary>Answer</summary>

   A stable name and address that sends traffic to whichever pods match its selector, even as pods are replaced.
   </details>

## Go deeper

- [Kubernetes: Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/), including CronJobs for running `logslayer` on a schedule.
