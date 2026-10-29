# HTTP and HTTPS

## Why this matters

Almost every app you'll defend talks HTTP: websites, APIs, cloud services. The AWS console you'll use in Module 6 is HTTPS calls under the hood. When a web app breaks, the answer is usually in a status code or a header. When a web app gets attacked, the attack is usually in an HTTP request.

`curl` lets you see the whole conversation, both sides, as plain text.

## Do it

1. Make a request and watch it:

   ```bash
   curl -v http://example.com -o /dev/null
   ```

   Lines starting with `>` are what **you sent**. Lines starting with `<` are what the server **sent back**. `-o /dev/null` throws away the page itself so you can focus on the conversation:

   ```
   * Connected to example.com (104.20.23.154) port 80
   > GET / HTTP/1.1
   > Host: example.com
   > User-Agent: curl/8.7.1
   > Accept: */*
   >
   < HTTP/1.1 200 OK
   < Date: Thu, 29 Oct 2026 21:40:22 GMT
   < Content-Type: text/html; charset=utf-8
   < Server: cloudflare
   ```

2. Read the request:

   - `GET` is the **method**: what you want to do.
   - `/` is the **path**: which page.
   - `Host: example.com` is a **header**: extra information. One server can host many sites, so `Host` says which one you want.
   - `User-Agent` says what program you are. Attackers fake it all the time. (Remember the [log injection in Module 1](../01-ai-foundations/06-owasp-llm-top-10.md)? It hid in the user agent.)

3. Read the response. `200 OK` is the **status code**. Learn the families:

   | Code | Means | You'll see it when |
   |---|---|---|
   | **2xx** | Success | `200 OK`: here's your page |
   | **3xx** | Go somewhere else | `301`: moved permanently, often `http` → `https` |
   | **4xx** | You (the client) did something wrong | `401`: log in first. `403`: you're logged in but not allowed. `404`: no such page. |
   | **5xx** | The server broke | `500`: the app crashed. `502`/`503`: the server behind it is down. |

   **4xx is the client's problem, 5xx is the server's.** That one rule tells you which team gets the ticket.

4. Learn the main methods: `GET` reads, `POST` sends data (like a login form), `PUT` replaces, `DELETE` deletes. Just headers, no page: `curl -I` sends a `HEAD` request:

   ```bash
   curl -I https://example.com
   ```

5. Run your own web server and watch requests arrive. In one SSH session:

   ```bash
   mkdir -p ~/web && cd ~/web
   echo "<h1>lab web server</h1>" > index.html
   python3 -m http.server 8080
   ```

   In a second SSH session:

   ```bash
   curl -v http://localhost:8080/
   ```

   The first window logs the request as it arrives:

   ```
   127.0.0.1 - - [29/Oct/2026 21:45:01] "GET / HTTP/1.1" 200 -
   ```

   That's an **access log** line: who, when, what they asked for, and the status code. It's the same shape as the web server logs you'll analyze in a SOC. Leave the server running for the Break it.

## Break it

Make the server say no:

```bash
curl -i http://localhost:8080/admin
curl -i -d "user=alice&password=hunter2" http://localhost:8080/login
```

The first gets **`404`**: there's no `/admin`. The second gets **`501`**: this little server doesn't support `POST`. Check the server window: both requests are logged, with their status codes. A burst of `404`s for paths like `/admin`, `/wp-login.php`, and `/.env` in a real access log is someone scanning for weaknesses.

Now look at what you just sent. That `-d` request carried a password, over `http://`. Anyone between you and the server could read it. You'll prove that in [lesson 9](09-seeing-the-traffic.md). For now, try HTTPS against a site whose certificate is broken on purpose:

```bash
curl https://expired.badssl.com/
```

```
curl: (60) SSL certificate problem: certificate has expired
```

`curl` refuses to talk to it. That's the **S** in HTTPS doing its job, and it's the next lesson. Stop your server with `Ctrl+C`.

## With Claude

```bash
curl -sI https://github.com
```

Paste the headers into [claude.ai](https://claude.ai) or Claude Code:

```text
Explain each of these HTTP response headers. Which ones are about security,
and what do they protect against?
```

**Check the work:** for any security header Claude explains, like `strict-transport-security` or `content-security-policy`, look it up on [MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers). Did Claude describe the header that's actually in the output, or a general list of headers that "should" be there? Did it invent a header that isn't in your output at all? Compare line by line.

## Check yourself

1. A user gets a `403`. Is the server down?
   <details><summary>Answer</summary>

   No. The server is up and answered: it understood the request and refused it. The user isn't allowed to see that page.
   </details>

2. Your app's logs show a spike in `502` errors. Whose problem is it, roughly?
   <details><summary>Answer</summary>

   The server side. A 5xx means a server broke. A 502 usually means a front-end server or load balancer couldn't get an answer from the app behind it.
   </details>

3. What does the `Host` header do?
   <details><summary>Answer</summary>

   It says which website you want, so one server at one IP address can host many sites.
   </details>

## Go deeper

- [MDN: an overview of HTTP](https://developer.mozilla.org/en-US/docs/Web/HTTP/Overview): the best free reference for HTTP, from Mozilla.
