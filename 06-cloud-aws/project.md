# Project: the notes app, live

**Pillars:** ☁️ Cloud · 🪪 Identity · 🤖 AI

## Why this matters

You've built every piece. Now you put a face on it, draw it, and prove you can bring the whole thing up and down with one command. "I deployed a serverless app on AWS, entirely in OpenTofu, with least-privilege roles and secrets in Parameter Store" is a sentence most entry-level candidates can't say. The diagram is what lets an interviewer follow it in thirty seconds.

## What to build

```text
notes-app/
├── README.md          # what it is, the diagram, how to deploy and destroy it
├── architecture.png   # or .md with a text diagram
├── frontend/
│   └── index.html
├── lambda/
│   ├── notes.py
│   └── audit.py
└── infra/
    ├── main.tf  variables.tf  outputs.tf  .gitignore  .terraform.lock.hcl
    ├── s3.tf  lambda.tf  api.tf  dynamodb.tf  sqs.tf
    ├── vpc.tf  ec2.tf  claude.tf
    └── frontend.tf
```

If your files drift from the lessons, the course has a [reference copy](reference/notes-app/) of where you should end up. Build it yourself first; use the reference to check.

## Steps

### 1. The front end

Create `frontend/index.html`:

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Notes</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 36rem; margin: 2rem auto; padding: 0 1rem; }
    li { margin: 0.5rem 0; }
  </style>
</head>
<body>
  <h1>Notes</h1>
  <form id="new">
    <input id="text" maxlength="500" placeholder="Write a note" required>
    <button>Add</button>
  </form>
  <ul id="notes"></ul>
  <script>
    const API = "${api_url}";

    async function load() {
      const notes = await (await fetch(API + "/notes")).json();
      const list = document.getElementById("notes");
      list.replaceChildren();
      for (const note of notes) {
        const item = document.createElement("li");
        item.textContent = note.text; // textContent, never innerHTML: a note can't inject code
        list.append(item);
      }
    }

    document.getElementById("new").addEventListener("submit", async (e) => {
      e.preventDefault();
      const input = document.getElementById("text");
      await fetch(API + "/notes", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ text: input.value }),
      });
      input.value = "";
      load();
    });

    load();
  </script>
</body>
</html>
```

`${api_url}` is filled in by OpenTofu when it uploads the page. And look at `textContent`: the page puts each note on the screen as **text**, never as HTML. If someone saves a note like `<img src=x onerror=alert(1)>`, it shows up as those characters, instead of running as code in every visitor's browser. That attack is called **cross-site scripting (XSS)**, and it's a form of the injection you met in [Module 3](../03-python/07-never-trust-input.md).

### 2. Host it privately, serve it publicly

Create `infra/frontend.tf`. The bucket stays **private**; only CloudFront, AWS's content delivery network, can read it, and CloudFront serves the page over HTTPS:

```hcl
resource "aws_s3_bucket" "site" {
  bucket_prefix = "${var.name}-site-"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  content_type = "text/html"
  content = templatefile("${path.module}/../frontend/index.html", {
    api_url = aws_apigatewayv2_api.notes.api_endpoint
  })
}

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${var.name}-site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "site"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id       = "site"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # AWS managed "CachingDisabled", so changes show up right away
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudfront.amazonaws.com" }
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.site.arn}/*"
      Condition = {
        StringEquals = { "AWS:SourceArn" = aws_cloudfront_distribution.site.arn }
      }
    }]
  })
}
```

Compare the bucket policy with the one you wrote in [lesson 4's Break it](04-storage.md). That one said `Principal = "*"`: anyone. This one says "the CloudFront service, and only when the request comes from **this** distribution." Block Public Access stays on, because this isn't public access.

### 3. Let the browser call the API

Browsers block a page from calling an API on a different domain unless the API says it's allowed (**CORS**). Allow your CloudFront site, and nothing else. In `api.tf`, add to `aws_apigatewayv2_api.notes`:

```hcl
  cors_configuration {
    allow_origins = ["https://${aws_cloudfront_distribution.site.domain_name}"]
    allow_methods = ["GET", "POST"]
    allow_headers = ["content-type"]
  }
```

`DELETE` isn't on the list: only you, with `curl` and the admin token, delete notes.

Add to `outputs.tf`:

```hcl
output "site_url" {
  value = "https://${aws_cloudfront_distribution.site.domain_name}"
}
```

### 4. Deploy from nothing

Prove the whole app comes up from code alone:

```bash
cd ~/my-security-portfolio/notes-app/infra
tofu destroy
tofu apply
```

CloudFront takes several minutes to deploy. Then open the `site_url` output in your laptop's browser. Add a note. Refresh. It's still there. Check `aws logs tail /aws/lambda/notes-audit --since 10m` for the audit line.

Try the XSS note from step 1. It shows as text.

### 5. Draw it

Draw the architecture: every service, and every arrow (who calls whom, and with which role). Use any free tool ([draw.io](https://www.drawio.com/) works in a browser), or paper and a photo, or a text diagram in Markdown. It must show:

- The browser, CloudFront, the site bucket
- API Gateway, the notes function and its role, DynamoDB, Parameter Store, SQS, the audit function and its role
- The files bucket
- The VPC with public and private subnets, the NACL, the security group, and the lab server
- Claude's read-only role, and the MCP server that uses it

Label each arrow with what's allowed. For example: "notes-lambda role: GetItem, PutItem, DeleteItem, Scan on notes-notes."

### 6. Write the README

`notes-app/README.md`:

- **What it is**, in two sentences, and the diagram
- **How to deploy it**, including the admin token step (`aws ssm put-parameter`), and **how to destroy it**
- **Security decisions**, one line each: private buckets behind CloudFront, least-privilege roles per function, the secret in Parameter Store and never in state, API throttling, CORS limited to the site, input validation, `textContent`, IMDSv2, SSH from one IP, Claude's view-only role
- **What I'd do next**: you'll fill this in through Modules 7–9

### 7. Commit, and tear it down

```bash
cd ~/my-security-portfolio
git add notes-app/
git status
git commit -m "Notes app: front end, diagram, and README"
git push
cd notes-app/infra && tofu destroy
```

Check `git status` before committing: no `.tfstate`, no `terraform.tfvars`, no `build/`.

## With Claude

With the app deployed, ask Claude Code (with the read-only AWS tools) to review it:

```text
Read the notes-app code and use the AWS tools to look at what's deployed.
Compare them: is anything deployed that isn't in the code, or configured
differently? Then list the three biggest security gaps you see.
```

**Check the work:** "deployed but not in the code" is called **drift**, and it matters, because your code is your inventory. Check any drift Claude reports with `tofu plan`, which shows differences between code and reality. For each security gap, decide whether it's real, already handled, or coming later in the course (identity in Module 7, the pipeline and closing SSH in Module 8, logging in Module 9). Put the real ones in your README's "What I'd do next."

## Done when

- [ ] `tofu apply` from an empty account brings up a working app, and `tofu destroy` removes all of it
- [ ] The site works in a browser, and an XSS note shows as plain text
- [ ] No secret appears in your repo, your `.tf` files, or your state (`grep` it)
- [ ] The diagram shows every service, role, and arrow
- [ ] The README explains how to deploy and destroy it, and why each security decision was made
- [ ] You can explain any line of any `.tf` file without looking it up

Then run your [end-of-session checklist](01-account-setup.md). Every time.
