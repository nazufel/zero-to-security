# Classes

**Pillars:** 🤖 AI

## Why this matters

As a tool grows, you end up passing the same bundle of values around: a user, an IP, whether it worked. A **class** bundles that data with the functions that work on it. You'll see classes in almost every Python library and in most AI-written code. You don't need to love them, but you need to read them, and to know when one is worth writing.

## Do it

1. So far, a parsed login is just a string (the IP). But you'll want more: who tried, from where, and whether it worked. Create `events.py`:

   ```python
   # events.py: a class for one login attempt

   class AuthEvent:
       """One SSH login attempt."""

       def __init__(self, user, ip, success):
           self.user = user
           self.ip = ip
           self.success = success

       def is_failure(self):
           return not self.success

       def describe(self):
           result = "succeeded" if self.success else "failed"
           return f"{self.user} from {self.ip}: {result}"


   attempts = [
       AuthEvent("deploy", "203.0.113.7", False),
       AuthEvent("deploy", "203.0.113.7", False),
       AuthEvent("deploy", "203.0.113.7", True),
       AuthEvent("root", "192.0.2.44", False),
   ]

   for attempt in attempts:
       print(attempt.describe())

   failures = [a for a in attempts if a.is_failure()]
   print(f"{len(failures)} failures")
   ```

   ```bash
   python3 events.py
   ```

   ```
   deploy from 203.0.113.7: failed
   deploy from 203.0.113.7: failed
   deploy from 203.0.113.7: succeeded
   root from 192.0.2.44: failed
   3 failures
   ```

2. Read it piece by piece:

   | Piece | What it is |
   |---|---|
   | `class AuthEvent:` | The blueprint. By convention, class names use `CapitalWords`. |
   | `__init__` | Runs when you create one: `AuthEvent("root", "192.0.2.44", False)` |
   | `self` | "This particular event." Every method gets it as its first parameter. |
   | `self.ip = ip` | Stores a value on this event, an **attribute** |
   | `is_failure`, `describe` | **Methods**: functions that belong to the class |
   | `attempt.ip`, `attempt.describe()` | Using an object's attributes and methods |

   `[a for a in attempts if a.is_failure()]` is a **list comprehension**, a one-line loop that builds a list. You'll see them everywhere.

3. Look at what the class bought you. The third `deploy` attempt **succeeded** after two failures from the same IP. With plain IP strings, that information was gone. With `AuthEvent`, it's right there. In Module 9, `logslayer` will use exactly this to detect a brute-force attack that worked.

**When is a class worth it?** When several values always travel together and have functions that only make sense for them, like this. When you just need to transform some data once, plain functions and dictionaries are simpler. Don't write a class because it looks professional.

## Break it

Forget `self` in a method:

```python
    def is_failure():
        return not self.success
```

```
Traceback (most recent call last):
  File "/home/you/my-security-portfolio/python/events.py", line 29, in <module>
    failures = [a for a in attempts if a.is_failure()]
                                       ~~~~~~~~~~~~^^
TypeError: AuthEvent.is_failure() takes 0 positional arguments but 1 was given
```

"0 positional arguments but 1 was given" sounds strange, since you called it with no arguments. Python passes the object itself as `self`, automatically. Your method didn't leave room for it. It's one of the most confusing errors for beginners, and now you know it. Put `self` back.

## With Claude

In `~/my-security-portfolio/python`, start `claude`:

```text
Read events.py. Would this be better as a Python dataclass? Show me what it
would look like, explain the difference, and tell me what I'd lose or gain.
Don't change the file.
```

**Check the work:** copy Claude's dataclass version into a new file, `events_dataclass.py`, and run it. Does it print exactly the same output? Then ask yourself the real question: can you explain every line of it? If not, the simpler version is the better one *for you*, right now. Code you can't explain isn't code you can review.

> **Free AI path:** do this with OpenCode; the prompt is the same.

```bash
git add events.py
git commit -m "Add AuthEvent class"
git push
```

## Check yourself

1. What's `self`?
   <details><summary>Answer</summary>

   The particular object a method was called on. Python passes it in automatically as the first argument.
   </details>

2. `e = AuthEvent("root", "192.0.2.44", False)`. What's `e.ip`? What's `e.is_failure()`?
   <details><summary>Answer</summary>

   `"192.0.2.44"`, and `True`.
   </details>

3. When should you *not* write a class?
   <details><summary>Answer</summary>

   When a function and a dictionary do the job just as clearly. Classes are for data and behavior that belong together, not for decoration.
   </details>

## Go deeper

- [Python tutorial: classes](https://docs.python.org/3/tutorial/classes.html): the official explanation, including inheritance, which you can skip for now.
