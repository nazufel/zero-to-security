# Network policies

**Pillars:** 🪪 Identity

## Why this matters

By default, every pod in a Kubernetes cluster can connect to every other pod, in every namespace. A bug in a public web server can become a connection to the database, the internal admin tool, and everything else. It's the flat network from the Target breach in [Module 8](../../08-security-concepts/04-network-segmentation.md), all over again.

A **NetworkPolicy** is a firewall rule for pods. The pattern is the one you already know: **default deny, then allow only the paths you need.**

## Do it

1. **See the open network first.** Start the toolbox pod (labeled `role: client`) and a second pod without that label:

   ```bash
   cd ~/my-security-portfolio/kubernetes/manifests
   kubectl apply -f toolbox.yaml
   sed 's/name: toolbox/name: stranger/; s/role: client/role: none/' toolbox.yaml | kubectl apply -f -
   kubectl wait -n logslayer --for=condition=Ready pod/toolbox pod/stranger
   ```

   Both can reach the web server through its Service:

   ```bash
   kubectl exec -n logslayer toolbox  -- wget -qO- -T 3 http://web | head -1
   kubectl exec -n logslayer stranger -- wget -qO- -T 3 http://web | head -1
   ```

2. **Read the policies.** Open [`netpol.yaml`](manifests/netpol.yaml):

   - `default-deny-ingress` selects **every** pod in the namespace (`podSelector: {}`) and allows no incoming traffic. Default deny.
   - `web-from-clients` allows incoming traffic to pods labeled `app: web`, only from pods labeled `role: client`, only on TCP 8080.

   Like security groups referencing security groups ([Module 8](../../08-security-concepts/04-network-segmentation.md)), the rules use **labels**, not IP addresses, because pod addresses change every time a pod is replaced.

3. **Apply and test:**

   ```bash
   kubectl apply -f netpol.yaml
   kubectl exec -n logslayer toolbox  -- wget -qO- -T 3 http://web | head -1
   kubectl exec -n logslayer stranger -- wget -qO- -T 3 http://web | head -1
   ```

   The toolbox still gets the page. The stranger gets `wget: download timed out`: a timeout, not "connection refused," exactly like a firewall drop in [Module 4](../../04-networking/03-tcp-udp-ports.md).

   > kind's built-in network plugin enforces network policies (since kind v0.24). Many clusters' plugins don't, and policies there are silently ignored. Always test that a deny actually denies.

4. Write in `kubernetes/notes.md` every path into the web pods that still exists, and why.

## Break it

Find the hole in the policy. The `web-from-clients` rule trusts **any pod** with the label `role: client`. Who decides a pod's labels? Whoever can create pods in the namespace. Relabel the stranger:

```bash
kubectl label pod -n logslayer stranger role=client --overwrite
kubectl exec -n logslayer stranger -- wget -qO- -T 3 http://web | head -1
```

It's in. A label is a claim, not an identity. Anyone who can create or edit pods in the namespace can give themselves any label, and walk through any label-based policy. That's why network policies are one layer: RBAC (lesson 4) must also limit who can create and label pods, or the network rules mean little.

Clean up: `kubectl delete pod -n logslayer stranger`.

## With Claude

Ask Claude Code:

```text
Read netpol.yaml. Add egress rules so that the web pods can't start any
outbound connections at all, and the toolbox can only reach the web pods and
cluster DNS. Explain each rule, then give me commands to test it.
```

**Check the work:** egress rules are where people break DNS. If the toolbox can't resolve `web` after the change, the policy forgot to allow DNS (UDP and TCP 53 to the `kube-dns` pods in `kube-system`). Run Claude's test commands, and add your own: can the toolbox still reach `web`? Can it reach the internet (`wget -T 3 https://example.com`)? Did the web pods lose anything they need?

## Check yourself

1. What does `podSelector: {}` select?
   <details><summary>Answer</summary>

   Every pod in the namespace.
   </details>

2. Why do network policies use labels instead of IP addresses?
   <details><summary>Answer</summary>

   Pod IP addresses change whenever pods are replaced. Labels stay with the workload.
   </details>

3. Who could get around a policy that trusts `role: client`?
   <details><summary>Answer</summary>

   Anyone who can create or label pods in that namespace. RBAC has to limit that for the policy to mean anything.
   </details>

## Go deeper

- [Kubernetes: network policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Network Policy Editor](https://editor.networkpolicy.io/): draw policies visually and see what they allow.
