# Module 5 quiz

Answer each question out loud or on paper *before* you open the answer.

1. A container and its host show the same kernel version. Why, and what does it mean for security?
   <details><summary>Answer</summary>

   Containers share the host's kernel; only VMs have their own. A kernel bug could let something escape a container, which is why this course runs containers inside a VM.
   </details>

2. A teammate adds themselves to the `docker` group "to save typing sudo." What's the risk?
   <details><summary>Answer</summary>

   The `docker` group is root-equivalent. Anyone in it, or any program they run, can mount the host's filesystem into a container and read or change anything.
   </details>

3. What's the difference between `-p 8080:8080` and `-p 127.0.0.1:8080:8080`?
   <details><summary>Answer</summary>

   The first publishes on every interface, reachable from the network, and Docker's rules bypass ufw. The second binds only to loopback, so only the host can reach it.
   </details>

4. A container needs to read `/var/log/auth.log`. Write the volume flag.
   <details><summary>Answer</summary>

   `-v /var/log/auth.log:/logs/auth.log:ro`. Mount only the file it needs, read-only.
   </details>

5. A Dockerfile does `COPY . .` and there's a `.env` file in the folder. What happens, and how do you prevent it?
   <details><summary>Answer</summary>

   The `.env` file, and any secrets in it, end up in the image for anyone who can pull it. Add `.env` to `.dockerignore`, and copy only the files the build needs.
   </details>

6. In a multi-stage build, why build in `python:latest-dev` and run in `python:latest`?
   <details><summary>Answer</summary>

   The `-dev` image has pip, a shell, and build tools to install the app. Only the final stage ships, so the runtime image contains just Python and the app.
   </details>

7. You run `docker run --entrypoint sh logslayer:chainguard` and get "executable file not found." Is the image broken?
   <details><summary>Answer</summary>

   No, that's the design. There's no shell, so an attacker who finds a bug can't use one either.
   </details>

8. Grype finds zero vulnerabilities in your image today. Is it secure?
   <details><summary>Answer</summary>

   It has no **known** vulnerabilities in the packages Grype could identify, today. New CVEs are published daily, and scanners miss things. Keep scanning and rebuilding.
   </details>

9. Why pin `FROM` by digest instead of by tag?
   <details><summary>Answer</summary>

   A tag can be moved to point at different content, which is what attackers did in the Trivy compromise. A digest is a hash of the content, so it always means the same image.
   </details>

10. What does each protect against: a digest, a signature, an SBOM?
    <details><summary>Answer</summary>

    Digest: getting different content than last time. Signature: content that didn't come from the identity you trust. SBOM: not knowing what's inside when a new vulnerability is announced.
    </details>

## Challenge

Without looking at the lessons, write a two-stage `Dockerfile` for `logslayer` on Chainguard from memory, build it, and prove four things with commands: it runs on the sample log, it runs as non-root, it has no shell, and Grype finds no high or critical vulnerabilities.

If you had to look anything up, do it again in a few days.
