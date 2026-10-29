# Working with files

## Why this matters

Almost everything on Linux is a file: config, logs, users, even devices. Fixing a server usually means editing one file correctly. Breaking a server usually means editing one file wrong, or deleting it, because the command line has no trash can and no "are you sure?"

## Do it

1. Make a workspace and some files:

   ```bash
   mkdir -p ~/lab/notes
   cd ~/lab
   touch first.txt
   ls
   ```

   `mkdir -p` makes a folder, and any parent folders it needs. `touch` makes an empty file.

2. Put text in a file and read it back:

   ```bash
   echo "hello from the lab" > first.txt
   echo "a second line" >> first.txt
   cat first.txt
   ```

   What you should see:

   ```
   hello from the lab
   a second line
   ```

   `>` writes to a file, **replacing** what was there. `>>` **adds** to the end. Remember the difference; the Break it step depends on it.

3. Copy, move, rename:

   ```bash
   cp first.txt backup.txt
   mv backup.txt notes/
   mv first.txt hello.txt
   ls . notes
   ```

   `mv` both moves and renames. There's no separate rename command.

4. Read a long file without flooding your screen:

   ```bash
   less /etc/services
   ```

   Space pages down, `/` searches, `q` quits. Search for `ssh` and see which port it uses.

5. Edit a file with **nano**, the beginner-friendly editor. Start your Linux cheat sheet:

   ```bash
   nano ~/lab/notes/linux-cheatsheet.md
   ```

   Type this, then add every command from lessons 2 and 3 in your own words:

   ```markdown
   # Linux cheat sheet

   | Command | What it does |
   |---|---|
   | `pwd` | Shows where I am |
   ```

   Save with `Ctrl+O` then Enter. Quit with `Ctrl+X`. The shortcuts are listed at the bottom of the screen (`^` means Ctrl).

   Add to this cheat sheet in every lesson. Writing it yourself is how the commands stick.

6. Delete:

   ```bash
   rm notes/backup.txt
   mkdir junk
   rm -r junk
   ```

   `rm -r` deletes a folder and everything in it.

## Break it

Overwrite something by accident:

```bash
echo "my important notes" > important.txt
echo "oops" > important.txt
cat important.txt
```

What you should see:

```
oops
```

One wrong character, `>` instead of `>>`, and your notes are gone. No warning, no undo.

Now delete it:

```bash
rm important.txt
cat important.txt
```

```
cat: important.txt: No such file or directory
```

There's no trash can. `rm` is forever. On a real server, that's why you make a backup copy before editing any config file:

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

Add "copy before you edit" to your cheat sheet.

## With Claude

Ask [claude.ai](https://claude.ai):

```text
Give me one Linux command that deletes every .tmp file in my current folder
and all folders under it.
```

It'll probably suggest something with `find` and `-delete` or `rm`. **Don't run it yet.**

**Check the work:** take the `-delete` or `rm` part off and run just the search first, so you see what *would* be deleted. Make a few test files to try it on:

```bash
touch a.tmp notes/b.tmp keep.txt
find . -name "*.tmp"
```

Only the `.tmp` files should show up. Once the preview is exactly right, add the delete back. **Preview first, delete second** goes for any destructive command, whether you wrote it or AI did.

## Check yourself

1. What's the difference between `>` and `>>`?
   <details><summary>Answer</summary>

   `>` replaces the file's contents. `>>` adds to the end. Mixing them up is a classic way to lose a config file.
   </details>

2. How do you rename `draft.txt` to `final.txt`?
   <details><summary>Answer</summary>

   `mv draft.txt final.txt`. Moving and renaming are the same command.
   </details>

3. You're about to edit `/etc/ssh/sshd_config`. What do you do first?
   <details><summary>Answer</summary>

   Copy it to a backup, like `sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak`. Then a bad edit can be undone. (On your VM, a snapshot works too.)
   </details>

## Go deeper

- [The nano editor guide](https://www.nano-editor.org/docs.php): official docs. Later, try `vimtutor` in your VM if you want to learn vim, the editor you'll find on every server.
