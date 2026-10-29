# Permissions

**Pillars:** 🪪 Identity

## Why this matters

Permissions decide who can read, change, or run every file on the system. This is where identity starts: before AWS roles and IAM policies, there's the question "who is allowed to read this file?"

Get it wrong one way and attackers read your secrets. Get it wrong the other way and your app breaks. The most common bad fix you'll see at work, `chmod 777`, gets it wrong both ways at once.

## Do it

1. Look at a file's permissions:

   ```bash
   cd ~/lab
   ls -l hello.txt
   ```

   What you should see:

   ```
   -rw-rw-r-- 1 yourusername yourusername 33 Mar 14 02:15 hello.txt
   ```

2. Read it left to right:

   ```
   -    rw-     rw-     r--     yourusername   yourusername
   type owner   group   others  owner          group
   ```

   - The first character is the type: `-` for a file, `d` for a directory.
   - Then three sets of three: what the **owner** can do, what the **group** can do, and what **everyone else** can do.
   - `r` is read, `w` is write, `x` is execute (run it, or for a folder, enter it). `-` means no.

3. Permissions as numbers. Each letter has a value: `r` = 4, `w` = 2, `x` = 1. Add them up for each set:

   | Number | Letters | Means | Typical use |
   |---|---|---|---|
   | `600` | `rw-------` | Only the owner can read and write | Private keys, secrets |
   | `644` | `rw-r--r--` | Owner writes, everyone reads | Normal files, public config |
   | `700` | `rwx------` | Only the owner can do anything | Private folders like `~/.ssh` |
   | `755` | `rwxr-xr-x` | Owner changes, everyone runs or enters | Programs, scripts, shared folders |

4. Change permissions with `chmod`:

   ```bash
   echo "my secret" > secret.txt
   chmod 600 secret.txt
   ls -l secret.txt
   ```

   ```
   -rw------- 1 yourusername yourusername 10 Mar 14 02:16 secret.txt
   ```

5. Make a script and run it:

   ```bash
   echo 'echo "it ran"' > hello.sh
   ./hello.sh
   ```

   ```
   -bash: ./hello.sh: Permission denied
   ```

   It's not executable. Fix it:

   ```bash
   chmod 755 hello.sh
   ./hello.sh
   ```

   ```
   it ran
   ```

6. Change the owner with `chown`. Only an admin can give files away, so it needs `sudo`:

   ```bash
   sudo chown root:root secret.txt
   cat secret.txt
   ```

   ```
   cat: secret.txt: Permission denied
   ```

   You own the folder, but root owns the file now, and `600` means only root can read it. Give it back:

   ```bash
   sudo chown $USER:$USER secret.txt
   cat secret.txt
   ```

   **`sudo`** runs one command as root. Root ignores permissions entirely. That's why who's allowed to use `sudo` is one of the most important questions on any server (lesson 7).

Add `chmod`, `chown`, `sudo`, and the number table to your cheat sheet.

## Break it

Try to read another user's private file. Every Linux system has one: `/etc/shadow` holds the password hashes for every account.

```bash
cat /etc/shadow
```

```
cat: /etc/shadow: Permission denied
```

```bash
ls -l /etc/shadow
```

```
-rw-r----- 1 root shadow 1024 Mar 14 01:02 /etc/shadow
```

Root can read and write. The `shadow` group can read. Everyone else gets nothing. If this file were `644`, any user, or any attacker who got into any account, could copy every password hash and try to crack them offline.

Now:

```bash
sudo cat /etc/shadow
```

It works. Find your own username in the output. The long string after it is your password's hash. Your password itself isn't stored anywhere; you'll learn why in Module 4.

Permissions protect files from users. Nothing protects them from root. Guard `sudo`.

## With Claude

Ask [claude.ai](https://claude.ai):

```text
My script fails with "Permission denied" when my web server tries to read
/var/www/data/config.txt. How do I fix it?
```

**Check the work:** read the answer for `chmod 777`, `chmod -R 777`, or "just run it as root." Those make the error go away by giving **everyone** full access, which is how a small bug becomes a breach. A good answer asks which user the web server runs as, then gives *that* user only the access it needs. If Claude suggested 777, ask it why that's dangerous, and add an entry to your [AI check log](../01-ai-foundations/01-what-ai-is.md).

## Check yourself

1. What does `chmod 640 report.txt` allow?
   <details><summary>Answer</summary>

   Owner reads and writes (6), group reads (4), everyone else nothing (0).
   </details>

2. Your SSH private key has permissions `644`. What's wrong?
   <details><summary>Answer</summary>

   Everyone on the system can read it. Private keys should be `600`. SSH will actually refuse to use a key that's too open.
   </details>

3. A coworker fixes a "Permission denied" error with `chmod 777`. What do you tell them?
   <details><summary>Answer</summary>

   It works by letting every user and process read, change, and run the file. Find out which user needs access and grant only that.
   </details>

## Go deeper

- [Chmod calculator](https://chmod-calculator.com/): click boxes, see the numbers. Useful until the numbers become automatic.
