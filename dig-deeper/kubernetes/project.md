# Project: a locked-down namespace

**Pillars:** 🪪 Identity · 🤖 AI

## Why this matters

One namespace, done properly, shows everything an interviewer wants to know about your Kubernetes security judgment: who can do what, what each workload can reach, and how tightly each container is boxed in, with tests that prove it.

## What to build

In `~/my-security-portfolio/kubernetes/`:

- `manifests/`: the namespace, `logslayer` Job (on a schedule now: a **CronJob** every hour), the web Deployment and Service, RBAC, network policies, all with images pinned by digest
- `test-access.sh`: a script of `kubectl auth can-i` checks for every identity, each one that **should** pass and one that **should not**, printing PASS or FAIL and exiting non-zero on any failure ([Module 7, lesson 5](../../07-identity/05-evaluation-logic.md))
- `README.md`: what's in the namespace, a diagram of who can reach what, and every accepted Checkov finding with a reason

## Steps

1. Turn the Job into a CronJob that runs hourly (`kind: CronJob`, with the Job's template under `spec.jobTemplate`). Check it runs: `kubectl get cronjob,jobs -n logslayer`.
2. Pin every image by digest.
3. Add egress policies so the web pods can't start outbound connections, and only DNS and the web Service are reachable from the toolbox ([lesson 6](06-network-policies.md)).
4. Write `test-access.sh`, run it, then break one Role on purpose and show it fails.
5. Scan: `uvx checkov@3.4.0 --directory manifests --framework kubernetes`. Fix or record each finding.
6. Recreate everything from scratch to prove it's all in the files:

   ```bash
   sudo kind delete cluster --name lab && sudo kind create cluster --name lab
   sudo kind get kubeconfig --name lab > ~/.kube/config
   sudo kind load docker-image logslayer:chainguard --name lab
   kubectl apply -f manifests/namespace.yaml && kubectl apply -f manifests/
   ./test-access.sh
   ```

7. Commit, and add a row to your portfolio README. Then `sudo kind delete cluster --name lab`.

## With Claude

Ask Claude to attack your namespace as a reviewer: "Assume an attacker controls the web container. List everything they can reach and every way they might gain more access." Check every claim with `kubectl auth can-i` and a network test from inside a pod. Fix what's real.

## Done when

- [ ] Everything comes back from an empty cluster with two `kubectl apply` commands
- [ ] `test-access.sh` passes, and fails when you break a Role
- [ ] Every Checkov finding is fixed or explained
- [ ] You can explain the diagram, every arrow and every missing arrow, out loud
