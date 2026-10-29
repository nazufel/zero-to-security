# Shared responsibility

**Pillars:** ☁️ Cloud

## Why this matters

In 2019, an attacker stole data on about 100 million Capital One customers from AWS. AWS wasn't hacked. A misconfigured web application firewall let the attacker trick a server into handing over the temporary credentials of its IAM role, and that role had permission to read far more S3 data than it needed. Every mistake was on the customer's side of the line.

AWS calls that line the **shared responsibility model**: AWS secures the cloud itself, and you secure what you put in it. Knowing exactly where the line falls, service by service, tells you what you have to protect.

## The line

| AWS is responsible for… | You are responsible for… |
|---|---|
| Data centers, power, physical security | Who can log in, and what they can do (IAM) |
| The hardware and the network between data centers | Your data, and whether it's encrypted and private |
| The software that runs each service | How you configure each service |
| | Your code, and the packages it uses |

The line **moves** depending on the service:

| Service | AWS handles | You handle |
|---|---|---|
| **EC2** (a virtual server) | The hardware and the hypervisor | The operating system and its patches, the firewall, everything installed, the data |
| **Lambda** (code that runs on request) | Servers, OS, patches, the Python runtime, scaling | Your code, its packages, its IAM role, what it's allowed to touch |
| **S3** (file storage) | Durability, the storage hardware, the service | Who can read and write, encryption settings, whether it's public |

The more managed the service, the less you have to patch, and the more of your security comes down to **configuration and identity**.

## Do it

1. Sign in to the console as `admin`. Open **EC2 → Launch instance**, but don't launch anything. Look at the choices you'd have to make: which operating system, which network, which firewall rules (security group), which key. Every one of those is yours to get right.

2. Open **Lambda → Create function**, and again don't create anything. Notice what you **don't** choose: no operating system, no patches, no firewall. You choose a runtime (like Python 3.14) and a role.

3. Open **S3 → Create bucket** and scroll through, without creating it. Find **Block Public Access** (on by default) and **Default encryption**. AWS made these the safe default after years of leaked-bucket headlines. Turning them off is your choice, and your responsibility.

4. Create `cloud/shared-responsibility.md` in your portfolio. For each of EC2, Lambda, and S3, list three things that would be **your** fault if they went wrong. Then add the notes app you'll build in this module:

   ```markdown
   | Notes app part | Service | What I must get right |
   |---|---|---|
   | Front end | S3 + CloudFront | |
   | API | API Gateway + Lambda | |
   | Data | DynamoDB | |
   | Secrets | Parameter Store | |
   | One server | EC2 | |
   ```

## Break it

Walk through Capital One's breach with the table in hand. For each step, decide whose side of the line it was on:

1. A web application firewall on EC2 was misconfigured.
2. The attacker made it send requests to the EC2 **instance metadata service**, an internal address every EC2 instance can call to get its role's temporary credentials.
3. The role had permission to list and read many S3 buckets.
4. The attacker used the credentials to copy the data out.

<details><summary>Whose side?</summary>

All four were the customer's. AWS's services worked as designed. The firewall configuration, the metadata settings, and the role's permissions were all Capital One's to get right. Two fixes you'll apply in this module: **IMDSv2**, which makes that kind of metadata trick much harder (lesson 5), and **least-privilege roles**, so stolen credentials can't reach much (Module 7).
</details>

## With Claude

Ask Claude Code:

```text
For a Lambda function that reads from DynamoDB, explain exactly which
security tasks are AWS's responsibility and which are mine.
```

**Check the work:** compare with the tables in this lesson. Is the line in the right place? A common mistake is saying AWS handles "security of the function," which is vague. Your code, its packages, its environment variables, and its IAM role are yours. Did Claude mention the role? It's the biggest one.

```bash
git add cloud/shared-responsibility.md
git commit -m "Add shared responsibility notes"
git push
```

## Check yourself

1. Your EC2 instance gets hacked through an unpatched package. Whose responsibility was the patch?
   <details><summary>Answer</summary>

   Yours. On EC2, the operating system and everything installed on it are the customer's.
   </details>

2. Who patches the Python runtime for your Lambda function?
   <details><summary>Answer</summary>

   AWS, for the managed runtime. You're still responsible for your code and the packages it includes.
   </details>

3. An S3 bucket is accidentally made public. Whose side of the line is that?
   <details><summary>Answer</summary>

   Yours. Access settings are configuration, and configuration belongs to the customer.
   </details>

## Go deeper

- [AWS shared responsibility model](https://aws.amazon.com/compliance/shared-responsibility-model/): AWS's own explanation and diagram.
