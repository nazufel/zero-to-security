# Seeing the traffic

## Why this matters

Everything so far, you've taken on trust: that DNS sends a question and gets an answer, that HTTP sends your password in plain text, that HTTPS doesn't. A **packet capture** lets you see it for yourself, byte by byte. When two teams argue about whose side is broken, the capture settles it. When a SOC needs to know what an attacker sent, the capture is the evidence.

You'll use two tools: **tcpdump**, the command-line capture tool on every Linux server, and **Wireshark**, the free desktop app for reading captures.

## Do it

1. Install tcpdump if it isn't there, and watch DNS happen live. In one SSH session:

   ```bash
   sudo apt install -y tcpdump
   sudo tcpdump -i any -n port 53
   ```

   In a second session:

   ```bash
   dig example.com
   ```

   The first window shows the question and the answer:

   ```
   02:31:07.114 lo    In  IP 127.0.0.1.41234 > 127.0.0.53.53: 12345+ A? example.com. (40)
   02:31:07.140 lo    In  IP 127.0.0.53.53 > 127.0.0.1.41234: 12345 2/0/0 A 104.20.23.154, A 172.66.147.243 (72)
   ```

   Source `IP.port` `>` destination `IP.port`, then what's inside: `A? example.com.` is the question, and `A 104.20.23.154` is the answer. You may see a second pair going out to your real DNS server. `-i any` captures on every interface, and `-n` shows numbers instead of names. Press `Ctrl+C` to stop.

2. **See a password in plain HTTP.** Start the web server from [lesson 6](06-http.md) in the background, then capture on loopback with `-A`, which prints packet contents as text:

   ```bash
   cd ~/web
   python3 -m http.server 8080 &
   sudo tcpdump -i lo -A -n port 8080
   ```

   In your second session, log in, the insecure way:

   ```bash
   curl -s -d "user=alice&password=hunter2" http://localhost:8080/login
   ```

   Look through the capture output:

   ```
   POST /login HTTP/1.1
   Host: localhost:8080
   User-Agent: curl/8.18.0
   Content-Type: application/x-www-form-urlencoded

   user=alice&password=hunter2
   ```

   There it is, in the clear. Anyone who can capture traffic on the path, on a coffee shop's Wi-Fi, a compromised router, or a cloud network, reads it exactly like this. Stop the capture with `Ctrl+C`.

3. **Now the same thing over HTTPS:**

   ```bash
   sudo tcpdump -i any -A -n port 443
   ```

   Second session:

   ```bash
   curl -s -d "user=alice&password=hunter2" https://example.com/ -o /dev/null
   ```

   The capture is gibberish. No `POST`, no `password`, no `hunter2`. Look closely, though, and you'll find `example.com` in plain text near the start. HTTPS hides **what** you said, but not **who** you talked to: the IP address and the site name (sent in a field called **SNI**) are visible. That's worth knowing when someone says HTTPS makes them anonymous.

4. **Save a capture and open it in Wireshark.** Capture both requests to a file:

   ```bash
   sudo tcpdump -i any -n -w ~/http-vs-https.pcap port 8080 or port 443
   ```

   Second session:

   ```bash
   curl -s -d "user=alice&password=hunter2" http://localhost:8080/login
   curl -s -d "user=alice&password=hunter2" https://example.com/ -o /dev/null
   ```

   Stop the capture, then make the file yours so you can copy it:

   ```bash
   sudo chown $USER ~/http-vs-https.pcap
   ```

   **On your laptop**, install [Wireshark](https://www.wireshark.org/download.html) (free), and copy the file over with `scp`, which is "copy over SSH":

   ```bash
   scp lab:http-vs-https.pcap .
   ```

   Open it in Wireshark. Then:

   - Type `http` in the filter bar and press Enter. Right-click the `POST` packet → **Follow → HTTP Stream**. The whole conversation, password included.
   - Change the filter to `tls`. Click the **Client Hello** packet, and expand **Transport Layer Security → Handshake → Extension: server_name**. There's `example.com`. Everything after the handshake shows only as **Application Data**.
   - Change the filter to `tcp.flags.syn == 1`. These are the first packets of each TCP handshake from [lesson 3](03-tcp-udp-ports.md): SYN, then SYN-ACK.

   You'll annotate this capture for the module project. Keep the file.

5. Stop the background web server:

   ```bash
   kill %1
   ```

## Break it

Two ways a capture "doesn't work":

```bash
tcpdump -i any -n port 53
```

```
tcpdump: any: You don't have permission to perform this capture on that device
(socket: Operation not permitted)
```

Capturing needs root, and for good reason: a capture sees **everyone's** traffic on that interface, not just yours. Who can run tcpdump on a server is a security decision.

Now capture on the wrong interface. Start the web server again (`python3 -m http.server 8080 &`), then:

```bash
sudo tcpdump -n port 8080
```

In the other session, `curl -s http://localhost:8080/`. The capture shows **nothing**. Without `-i`, tcpdump picks your main network interface, and traffic to `localhost` never touches it; it stays on `lo`. "My capture is empty" usually means the wrong interface or the wrong filter, not that there was no traffic. Stop it, and `kill %1`.

## With Claude

Run a short capture of your HTTP request, as text:

```bash
sudo tcpdump -i lo -n -v port 8080
```

Paste the output into [claude.ai](https://claude.ai) or Claude Code (it's your own lab traffic, so that's fine):

```text
Explain this packet capture line by line. Point out the TCP handshake, the
HTTP request, the response, and how the connection closes.
```

**Check the work:** open the same conversation in Wireshark and follow along. Does each packet Claude describes exist, in that order? Check the flags it names (`[S]` is SYN, `[S.]` is SYN-ACK, `[.]` is ACK, `[P.]` is data, `[F.]` is FIN) against the actual lines. Did it describe a handshake that "should" happen rather than the one in your capture? Captures are evidence. An explanation that doesn't match the evidence is wrong, however confident it sounds.

## Check yourself

1. What can someone capturing your traffic see over HTTP? Over HTTPS?
   <details><summary>Answer</summary>

   HTTP: everything, including passwords and cookies. HTTPS: the IP addresses, the site name (SNI), and roughly how much data was sent, but not the content.
   </details>

2. Your tcpdump capture of a local web server is empty. What's the first thing you check?
   <details><summary>Answer</summary>

   The interface. Traffic to `localhost` is on `lo`, so use `-i lo` or `-i any`.
   </details>

3. Why does tcpdump need `sudo`?
   <details><summary>Answer</summary>

   It can see all traffic on an interface, including other users' and other programs'. That's too powerful for a normal user.
   </details>

## Go deeper

- [Wireshark User's Guide](https://www.wireshark.org/docs/wsug_html_chunked/): official docs. Chapter 6 covers display filters, which are most of the skill.
- [Malware-Traffic-Analysis.net](https://www.malware-traffic-analysis.net/): free real-world captures with exercises, for when you want to practice SOC-style analysis.
