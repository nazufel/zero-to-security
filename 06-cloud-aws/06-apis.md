# APIs: API Gateway

**Pillars:** ☁️ Cloud

## Why this matters

A Lambda function on its own can only be called by someone with AWS credentials. To let a browser or an app call it over HTTPS, you put **API Gateway** in front: it accepts web requests, passes them to Lambda, and passes the answers back. It's the front door of the notes app, and front doors need limits. An API with no request limit is an invitation to run up your bill, or to knock you offline.

## Do it

**Console:** open **API Gateway** and click **Create API**. Look at the choices: **HTTP API** (simple, cheaper) and **REST API** (more features). This course uses HTTP APIs. Don't create one.

**Code:**

1. Create `infra/api.tf`:

   ```hcl
   resource "aws_apigatewayv2_api" "notes" {
     name          = "${var.name}-api"
     protocol_type = "HTTP"
   }

   resource "aws_apigatewayv2_integration" "notes" {
     api_id                 = aws_apigatewayv2_api.notes.id
     integration_type       = "AWS_PROXY"
     integration_uri        = aws_lambda_function.notes.invoke_arn
     payload_format_version = "2.0"
   }

   resource "aws_apigatewayv2_route" "notes" {
     for_each = toset(["GET /notes"])

     api_id    = aws_apigatewayv2_api.notes.id
     route_key = each.value
     target    = "integrations/${aws_apigatewayv2_integration.notes.id}"
   }

   resource "aws_apigatewayv2_stage" "default" {
     api_id      = aws_apigatewayv2_api.notes.id
     name        = "$default"
     auto_deploy = true

     default_route_settings {
       throttling_burst_limit = 10
       throttling_rate_limit  = 5
     }
   }

   resource "aws_lambda_permission" "api" {
     statement_id  = "AllowApiGateway"
     action        = "lambda:InvokeFunction"
     function_name = aws_lambda_function.notes.function_name
     principal     = "apigateway.amazonaws.com"
     source_arn    = "${aws_apigatewayv2_api.notes.execution_arn}/*/*"
   }
   ```

   | Resource | What it does |
   |---|---|
   | `aws_apigatewayv2_api` | The API itself, with its own HTTPS address |
   | `integration` | "Send requests to this Lambda function" |
   | `route` | Which method and path go to the integration. `for_each` makes one route per item in the list. |
   | `stage` | Publishes the API. `throttling` caps it at 5 requests per second, bursts of 10. |
   | `aws_lambda_permission` | A **resource-based policy** on the function: "API Gateway, for this API only, may call me." Without it, API Gateway gets access denied. |

2. Add the URL to `outputs.tf`:

   ```hcl
   output "api_url" {
     value = aws_apigatewayv2_api.notes.api_endpoint
   }
   ```

3. Apply and call it like any website would ([Module 4](../04-networking/06-http.md)):

   ```bash
   tofu apply
   API=$(tofu output -raw api_url)
   curl -i "$API/notes"
   ```

   ```
   HTTP/2 200
   content-type: application/json
   ...

   {"message": "hello from Lambda"}
   ```

   HTTPS, a certificate, and a public address, without you managing a server.

4. Try a route that doesn't exist:

   ```bash
   curl -i "$API/admin"
   ```

   ```
   HTTP/2 404
   {"message":"Not Found"}
   ```

   API Gateway answered and never woke the function. Only the routes you list exist.

5. Commit:

   ```bash
   git add api.tf outputs.tf
   git commit -m "Put API Gateway in front of the Lambda function"
   git push
   ```

## Break it

Flood your own API and watch the throttle hold. Send 50 requests at once, and count the status codes that come back:

```bash
{ for i in $(seq 50); do curl -s -o /dev/null -w "%{http_code}\n" "$API/notes" & done; wait; } | sort | uniq -c
```

Roughly:

```
     12 200
     38 429
```

`429 Too Many Requests`: API Gateway turned most of them away without calling Lambda. On the internet, a bot or an angry user can send millions of requests. Without a limit, every one runs your function, and on a paid account, every one costs money. (This is OWASP's "unbounded consumption," and a denial of service, in one.) The limit is your first line of defense against both.

Now remove the `default_route_settings` block, apply, and run the flood again: all 200s. Put it back and apply.

## With Claude

Ask Claude Code:

```text
Read api.tf. What would someone on the internet be able to do with this API
right now? What protections does it have, and what's missing?
```

**Check the work:** it should notice there's **no authentication**: anyone with the URL can call it. For a public notes demo, that's a choice you're making on purpose, and you'll protect the one dangerous route (delete) in lesson 8. Did Claude suggest an authorizer, an API key, or AWS WAF? Note them; at work, you'd use one. Did it notice the throttle? Did it claim the throttle is per user? It isn't; it's for the whole API. Check against the [docs](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-throttling.html).

## Check yourself

1. What does `aws_lambda_permission` do here?
   <details><summary>Answer</summary>

   It's a resource-based policy on the function that lets API Gateway, from this API only, invoke it. Without it, API Gateway can't call the function.
   </details>

2. What does a `429` status mean?
   <details><summary>Answer</summary>

   Too many requests: you've been throttled. It's the client's problem (4xx), so slow down.
   </details>

3. Why throttle an API that only you use?
   <details><summary>Answer</summary>

   Because it's public: anyone who finds the URL can call it. A limit caps the cost and the load from abuse.
   </details>

## Go deeper

- [API Gateway: HTTP APIs](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api.html): routes, integrations, throttling, and authorizers.
