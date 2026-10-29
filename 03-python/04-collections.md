# Collections

**Pillars:** 🤖 AI

## Why this matters

Security data comes in piles: a thousand log lines, fifty IP addresses, a list of users with `sudo`. Python has two containers you'll use every day: a **list** for things in order, and a **dictionary** for looking things up by name. "Count failed logins per IP," the heart of `logslayer`, is a dictionary.

## Do it

1. **Lists** hold items in order. Create `collections_practice.py`:

   ```python
   # collections_practice.py: lists and dictionaries

   ips = ["203.0.113.7", "192.0.2.44", "203.0.113.7", "198.51.100.23"]

   print(ips[0])        # first item
   print(ips[-1])       # last item
   print(len(ips))      # how many
   ips.append("10.0.2.2")
   print(ips)
   print("192.0.2.44" in ips)
   ```

   ```
   203.0.113.7
   198.51.100.23
   4
   ['203.0.113.7', '192.0.2.44', '203.0.113.7', '198.51.100.23', '10.0.2.2']
   True
   ```

   Counting starts at **0**, not 1. `-1` counts from the end.

2. **Splitting** a string gives you a list. This is how you'll pull pieces out of a log line:

   ```python
   line = "Failed password for root from 192.0.2.44 port 55001 ssh2"
   words = line.split()
   print(words)
   print(words[3])
   print(words[-4])
   ```

   ```
   ['Failed', 'password', 'for', 'root', 'from', '192.0.2.44', 'port', '55001', 'ssh2']
   root
   192.0.2.44
   ```

   `split()` breaks text on spaces. The username is item `3`. The IP is 4th from the end.

3. **Dictionaries** map a **key** to a **value**, like a phone book:

   ```python
   user_groups = {"alice": "developers", "bob": "sudo"}
   print(user_groups["bob"])
   user_groups["carol"] = "auditors"
   print(user_groups)
   print("dave" in user_groups)
   ```

   ```
   sudo
   {'alice': 'developers', 'bob': 'sudo', 'carol': 'auditors'}
   False
   ```

4. Now the pattern you'll use in `logslayer`: **count things with a dictionary.**

   ```python
   counts = {}
   for ip in ips:
       counts[ip] = counts.get(ip, 0) + 1
   print(counts)
   ```

   ```
   {'203.0.113.7': 2, '192.0.2.44': 1, '198.51.100.23': 1, '10.0.2.2': 1}
   ```

   `counts.get(ip, 0)` means "the current count for this IP, or 0 if we haven't seen it yet."

5. Sort by count, worst first, and loop over the results:

   ```python
   for ip in sorted(counts, key=counts.get, reverse=True):
       print(ip, counts[ip])
   ```

   ```
   203.0.113.7 2
   192.0.2.44 1
   198.51.100.23 1
   10.0.2.2 1
   ```

   `key=counts.get` means "sort the IPs by their count." `reverse=True` puts the biggest first. That's `sort | uniq -c | sort -rn` from Module 2, in Python.

## Break it

Count the "obvious" way, without `.get()`, in a new file called `keyerror.py`:

```python
counts = {}
counts["203.0.113.7"] += 1
```

```
Traceback (most recent call last):
  File "/home/you/my-security-portfolio/python/keyerror.py", line 2, in <module>
    counts["203.0.113.7"] += 1
    ~~~~~~^^^^^^^^^^^^^^^
KeyError: '203.0.113.7'
```

A `KeyError` means you asked for a key that isn't in the dictionary. You can't add 1 to a count that doesn't exist yet. `.get(key, 0)` handles the first time you see each IP.

Then try `words[20]` on the split line from step 2. That's an `IndexError`: there's no 21st word. Real log lines are sometimes shorter than you expect. You'll handle that in lessons 6 and 7.

## With Claude

In `~/my-security-portfolio/python`, start `claude`:

```text
In collections_practice.py, how else could I count items in Python besides
counts.get()? Show me the alternatives, but don't change my file.
```

It'll probably mention `collections.Counter` and `defaultdict`.

**Check the work:** try each suggestion in the REPL (`python3`) with the same `ips` list. Do they give the same counts? Is the output format the same, or does one print something different, like `Counter({...})`? Both are fine to use, but you should be able to explain the `.get()` version first, because that's what's happening underneath.

> **Free AI path:** do this with OpenCode; the prompt is the same.

```bash
git add collections_practice.py
git commit -m "Add lists and dictionaries practice"
git push
```

## Check yourself

1. `ports = [22, 80, 443]`. What's `ports[1]`? `ports[-1]`?
   <details><summary>Answer</summary>

   `80` and `443`. Lists count from 0, and `-1` is the last item.
   </details>

2. When do you use a list, and when a dictionary?
   <details><summary>Answer</summary>

   A list for things in order (log lines, a sequence of events). A dictionary when you look things up by a key (count per IP, groups per user).
   </details>

3. Why `counts.get(ip, 0) + 1` instead of `counts[ip] + 1`?
   <details><summary>Answer</summary>

   The first time an IP appears, it isn't in the dictionary, so `counts[ip]` raises a `KeyError`. `.get(ip, 0)` starts it at 0.
   </details>

## Go deeper

- [Python tutorial: data structures](https://docs.python.org/3/tutorial/datastructures.html): lists, dictionaries, and two you'll meet later, tuples and sets.
