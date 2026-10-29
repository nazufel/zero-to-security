# Scan it

**Pillars:** ☁️ Cloud · 🤖 AI

## Why this matters

Every package in an image might have a **CVE**: a publicly known vulnerability with an ID like `CVE-2026-12345`. Attackers read the same CVE lists you do. A scanner reads an image's list of packages and checks each one against those databases.

Scanning is daily work in cloud and security engineering. Interviewers like candidates who can show real numbers from their own scans, so in this lesson you'll make some.

## Do it

1. Install **Grype**, a free, open-source scanner. Read the installer first, as always:

   ```bash
   curl -sSfL https://get.anchore.io/grype -o grype-install.sh
   less grype-install.sh
   sudo sh grype-install.sh -b /usr/local/bin
   grype version
   ```

   > **Last verified:** 2026-10-29 with Grype 0.121 ([Grype on GitHub](https://github.com/anchore/grype)).

2. Scan the standard image:

   ```bash
   sudo grype logslayer:standard
   ```

   It reads the packages in the image, then lists each vulnerability it finds:

   ```
   NAME          INSTALLED   FIXED IN   TYPE   VULNERABILITY    SEVERITY
   libexpat1     2.7.1-2                deb    CVE-2026-xxxxx   High
   ...
   ```

   Scroll back to the summary at the top. Write down the count for each severity: critical, high, medium, low, negligible. Expect **hundreds**. Most come from software in the Debian base that `logslayer` never uses.

3. Scan the Chainguard image:

   ```bash
   sudo grype logslayer:chainguard
   ```

   Expect **zero, or very close to it**. Chainguard rebuilds its images constantly and ships fixes fast, and there's simply much less software in it to be vulnerable.

4. Record both scans in a table in `logslayer/README.md`. You'll use it in the project:

   ```markdown
   ## Image comparison

   | | `python:3.14` (standard) | Chainguard |
   |---|---|---|
   | Size | | |
   | Runs as | root | 65532 (nonroot) |
   | Shell | yes | no |
   | Critical / High CVEs | | |
   | Total CVEs | | |
   | Scanned on | | |
   ```

   Always write the date. Scan results change **every day** as new CVEs are published and fixed. Your numbers will differ from anyone else's, and from your own next week. That's not a problem with the scanner. It's why you scan continuously, not once.

5. Focus on what you can fix. Most teams care first about vulnerabilities that **have** a fix:

   ```bash
   sudo grype logslayer:standard --only-fixed
   ```

   If a fix exists, updating the base image usually gets it.

## Break it

Make the scan fail, the way a pipeline would. Grype can exit with an error if it finds anything at or above a severity you choose:

```bash
sudo grype logslayer:standard --fail-on high
echo "exit code: $?"
sudo grype logslayer:chainguard --fail-on high
echo "exit code: $?"
```

The standard image almost certainly fails (exit code `1`). The Chainguard image passes (`0`), as long as no high-severity CVE has been published against it today. That exit code is how a CI pipeline blocks a vulnerable image from shipping. You'll build exactly that in Module 8.

Scanners also miss things. Grype only knows about packages it can identify. A binary someone copied in by hand, or a vulnerability nobody has reported yet, won't show up. **A clean scan means "no known vulnerabilities in the packages I could see," not "secure."**

## With Claude

Save the standard image's results as JSON, and give Claude a manageable slice:

```bash
sudo grype logslayer:standard -o json > scan.json
sudo grype logslayer:standard --only-fixed | head -30 > scan-top.txt
```

In Claude Code:

```text
Read scan-top.txt. Which of these vulnerabilities would you fix first in an
image that runs a log-parsing CLI, and why? Then tell me the simplest way to
fix most of them.
```

**Check the work:** pick two CVE IDs Claude prioritized and look them up yourself on the [NVD](https://nvd.nist.gov/) or the [Debian security tracker](https://security-tracker.debian.org/tracker/). Does the description match what Claude said? Does the CVE even affect how `logslayer` runs? A vulnerability in a library the app never loads is real, but lower priority. And did Claude's "simplest fix" match what you already did: switch to a minimal base image? Delete `scan.json` and `scan-top.txt` when you're done.

> **Free AI path:** do this with OpenCode; the prompt is the same.

## Check yourself

1. What's a CVE?
   <details><summary>Answer</summary>

   A public ID for a known vulnerability, like `CVE-2026-12345`. Scanners match the packages in an image against CVE databases.
   </details>

2. Your scan is clean today. Will it be clean next month?
   <details><summary>Answer</summary>

   Not necessarily. New CVEs are published every day against software that hasn't changed. That's why you scan continuously and rebuild on fresh base images.
   </details>

3. Why do minimal images have far fewer CVEs?
   <details><summary>Answer</summary>

   Fewer packages means fewer things that can have vulnerabilities, and Chainguard rebuilds and patches its images constantly.
   </details>

## Go deeper

- [CISA Known Exploited Vulnerabilities catalog](https://www.cisa.gov/known-exploited-vulnerabilities-catalog): the CVEs attackers are actually using. If one is in your image, fix it first.
