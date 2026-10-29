# Account setup done right

**Pillars:** ☁️ Cloud · 🪪 Identity

## Why this matters

The first hour of an AWS account decides how bad its worst day can be. Accounts get taken over through a root login with no MFA. People get surprise bills from a server they forgot. Keys get leaked from a laptop and used to mine cryptocurrency on the victim's credit card. All three have the same fixes, and they take about 30 minutes.

**Read [AWS cost safety](../appendix/aws-cost-safety.md) before you start.** It's short.

## Do it

### 1. Create the account, on the Free plan

> **Last verified:** 2026-10-29 ([AWS Free Tier](https://aws.amazon.com/free/)). New accounts choose a **Free plan** or a **Paid plan**. On the Free plan you aren't charged unless you upgrade, and it ends after 6 months or when your credits run out.

1. Sign up at [aws.amazon.com](https://aws.amazon.com/). Use an email address you'll keep, and a long, unique password from a password manager.
2. When asked, choose the **Free plan**.
3. You'll be asked for a card for identity checks. On the Free plan, you won't be charged unless you upgrade.

The login you just made is the **root user**. It can do anything, including close the account. After this lesson, you'll almost never use it.

### 2. Protect root with MFA

1. Sign in as root. Top right, click your account name → **Security credentials**.
2. Under **Multi-factor authentication (MFA)**, click **Assign MFA device**. Use an authenticator app on your phone, or a passkey or security key.
3. Sign out and back in to prove it works.

### 3. Set a $1 budget alert

1. Search the console for **Billing and Cost Management** → **Budgets** → **Create budget**.
2. Choose the **Zero spend** or **Monthly cost** template, set the amount to **$1**, and enter your email.

If anything ever starts costing money, you'll know the same day.

### 4. Make an admin user for daily work

1. Go to **IAM** → **User groups** → **Create group**. Name it `admins` and attach the **AdministratorAccess** policy.
2. **IAM** → **Users** → **Create user**. Name it `admin`, check **Provide user access to the AWS Management Console**, and choose **I want to create an IAM user**. Add it to the `admins` group.
3. **Don't** create access keys. You won't need them, ever, in this course.
4. Copy the **console sign-in URL** shown at the end. It looks like `https://123456789012.signin.aws.amazon.com/console`. Bookmark it.
5. Sign out of root. Sign in at that URL as `admin`, open **Security credentials**, and assign MFA to this user too.

From now on, you work as `admin`. Permissions go on the group, not the user. You'll learn why in Module 7.

### 5. Pick one region

Top right of the console, pick the region closest to you (for example, `us-east-1` in Virginia or `eu-west-2` in London) and use it for **everything**. Resources in a region you forgot about are how people find a bill months later. This course's examples use `us-east-1`. If you pick another, change it everywhere you see it.

### 6. Connect your VM, with no keys

Your VM needs to talk to AWS, for the CLI, OpenTofu, and Python. The old way was an **access key**: a long-lived password stored in a file. Those leak constantly. You'll use `aws login` instead, which signs you in through the browser and gives the VM **temporary** credentials that expire on their own.

In your VM, install the AWS CLI:

```bash
sudo apt install -y unzip
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o awscliv2.zip
unzip -q awscliv2.zip
sudo ./aws/install
aws --version
rm -rf aws awscliv2.zip
```

You need version **2.32.0 or newer** for `aws login`.

> **Last verified:** 2026-10-29 ([AWS CLI: login with console credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sign-in.html)).

Sign in. The VM has no browser, so use `--remote`:

```bash
aws login --remote --profile me
```

Enter your region when asked. Open the link it prints on your laptop, sign in as `admin` (with MFA), and paste the code back. Then check who you are:

```bash
aws sts get-caller-identity --profile me
```

```json
{
    "UserId": "AIDAEXAMPLE1234567890",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/admin"
}
```

One more step. Some tools, including OpenTofu, may not read `aws login` sessions directly yet. Add a second profile that hands them the same temporary credentials. Open `~/.aws/config` with `nano` and add:

```ini
[profile lab]
credential_process = aws configure export-credentials --profile me --format process
region = us-east-1
```

Make it the default for your shell:

```bash
echo 'export AWS_PROFILE=lab' >> ~/.bashrc
source ~/.bashrc
aws sts get-caller-identity
```

Same answer, through the `lab` profile. Two names to remember: **`me`** is you signing in; **`lab`** is what your tools use. The credentials last up to 12 hours. When they expire, run `aws login --remote --profile me` again.

### 7. Write your end-of-session checklist

Create `~/my-security-portfolio/cloud/session-checklist.md`:

```markdown
# End of every AWS session

1. `tofu destroy` in every project I applied today
2. `aws logout --profile me`
3. Glance at Billing → Bills in the console: still $0.00?
```

Run it every time you stop working. It takes one minute.

## Break it

Try to do admin work as your tools, while signed out:

```bash
aws logout --profile me
aws s3 ls
```

It fails with an error about missing or expired credentials. (The exact wording depends on your CLI version. Read it: it usually tells you to run `aws login`.)

Nothing on the VM can reach your account. No key in a file, no session: no access. That's what you want when a laptop or VM is lost, or when an AI agent you're running goes looking for credentials. Sign back in:

```bash
aws login --remote --profile me
```

Now compare with the old way. Look at what's stored on disk:

```bash
ls ~/.aws/ ~/.aws/login/cache/
```

There's a cached **session** that expires, and no `credentials` file holding a permanent key. If someone copied your `.aws` folder today, it would be useless within hours. A leaked access key works until someone notices and deletes it, which for many companies is months.

## With Claude

Ask Claude Code:

```text
I just created an AWS account. List the security settings I should turn on
in the first hour, in order of importance.
```

**Check the work:** compare its list with this lesson. Does it tell you to create access keys for the CLI? That's the common, outdated answer. Push back: "What about aws login?" Does it suggest AWS Organizations or IAM Identity Center? Those are good at work, but on the Free plan, [joining an Organization ends your free credits](../appendix/aws-cost-safety.md). Did it mention anything that costs money, like GuardDuty or AWS Config, without saying so? Note what it got wrong in your [AI check log](../01-ai-foundations/01-what-ai-is.md).

```bash
cd ~/my-security-portfolio
git add cloud/session-checklist.md
git commit -m "Add AWS end-of-session checklist"
git push
```

## Check yourself

1. Why turn on MFA for root first?
   <details><summary>Answer</summary>

   Root can do anything, including close the account or remove everyone else's access, and its password is the only thing protecting it until MFA is on.
   </details>

2. Why `aws login` instead of an access key?
   <details><summary>Answer</summary>

   `aws login` gives temporary credentials that expire on their own. An access key works until someone deletes it, and leaked keys are one of the most common ways AWS accounts get compromised.
   </details>

3. Why use only one region?
   <details><summary>Answer</summary>

   So nothing is running somewhere you forgot to look. Forgotten resources in another region are a classic cause of surprise bills.
   </details>

## Go deeper

- [AWS security best practices in IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html): the official list. You'll recognize most of it by the end of Module 7.
