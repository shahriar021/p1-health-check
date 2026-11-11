# Server Health Check (Bash)

A small Bash script that checks the health of a machine: date, user, disk usage with a warning threshold, and uptime/load. It is my first DevOps project, built to practice Linux, Bash scripting, and Git.

## What the script does

1. Prints the date and the current user
2. Reads disk usage of the main data volume
3. Prints `WARNING` if usage is above 80%, otherwise `OK`
4. Prints uptime and load averages

Example output:

```
=== Health Check: Wed Nov 11 23:16:07 +06 2026 ===
User: devuser
--- Disk ---
Disk used: 88%
WARNING: disk is above 80%
--- Uptime ---
23:16  up 20 days,  3:16, 2 users, load averages: 1.84 1.76 1.56
```

## How to run

```bash
chmod +x health.sh          # allow the file to run (needed once)
./health.sh                 # print the report
./health.sh >> health.log   # append the report to a log file
```

Note: the disk row is matched with `grep "Data$"`, which is specific to macOS. On Linux, change it to match your root volume (for example `grep "/$"`).

---

# What I learned (with details)

## 1. Navigating the file system

| Command | What it does |
|---|---|
| `pwd` | Print working directory: where am I right now? |
| `cd ~` | Go to my home folder (`~` means home) |
| `cd folder` | Go into a folder |
| `ls -la` | List everything, including hidden files, with details |
| `mkdir -p a/b` | Make folders; `-p` also creates missing parent folders |
| `touch file` | Create an empty file |
| `cat file` | Print a file's contents |
| `rm file` | Delete a file (no recycle bin, be careful) |

A path starting with `/` is an **absolute path**, for example `/Users/name/devops-journey/p1-health-check`.

## 2. Reading system health

| Command | What it shows |
|---|---|
| `date` | Current date and time |
| `whoami` | Current username |
| `df -h` | Disk space; `-h` means human-readable (GB instead of bytes) |
| `uptime` | How long the machine has been on, plus load averages |
| `sysctl -n hw.ncpu` | Number of CPU cores (macOS) |

**Disk columns in `df -h`:** Filesystem, Size, Used, Avail, Capacity, Mounted on.
**Load average:** average number of busy processes over the last 1, 5, and 15 minutes. Compare it with the number of CPU cores. Load well below the core count is healthy (mine: about 1.8 load on 10 cores).

## 3. Pipes and filtering text

The pipe `|` sends the output of one command into the next.

```bash
df -h | grep "Data$" | awk '{print $5}' | tr -d '%'
```

| Tool | Job |
|---|---|
| `grep "text"` | Keep only the **lines** containing the text |
| `grep "Data$"` | `$` means end of line, so only lines ending with `Data` match |
| `awk '{print $5}'` | Keep only column 5 of each line (columns split by spaces) |
| `tr -d '%'` | Delete every `%` character |
| `head -5` | Keep only the first 5 lines |

Chain explained: `df` gives all lines, `grep` keeps one line, `awk` keeps one column, `tr` removes the `%` so the result is a plain number I can compare.

## 4. Output redirection

| Symbol | Meaning |
|---|---|
| `>` | Write output to a file and **overwrite** the old content |
| `>>` | **Append** output to the end of the file (used for logs) |

```bash
echo "one" > test.txt     # file contains: one
echo "two" > test.txt     # file contains: two (one is erased)
echo "three" >> test.txt  # file contains: two, three
```

Logs use `>>` so the history keeps growing.

## 5. File permissions

`ls -l` shows permissions like `-rwxr-xr-x`:

```
-   rwx   r-x   r-x
|    |     |     |
|    |     |     +-- others
|    |     +-------- group
|    +-------------- owner
+------------------- file type (- file, d directory)
```

| Letter | Meaning | Number |
|---|---|---|
| `r` | read | 4 |
| `w` | write | 2 |
| `x` | execute | 1 |

- A new file is `-rw-r--r--` (no `x`), so running it gives `permission denied`.
- `chmod +x file` adds execute permission. `chmod -x file` removes it.
- `chmod 755 file` = owner `rwx` (7), group and others `r-x` (5).
- On servers, give execute only to who needs it (for example `chmod 700`).
- On macOS, the `@` after the permissions means extended attributes. It is Mac-only and can be ignored.

## 6. Bash scripting basics

| Concept | Example | Meaning |
|---|---|---|
| Shebang | `#!/bin/bash` | First line; tells the system which program runs the file |
| Print | `echo "text"` | Print text |
| Command substitution | `$(date)` | Run a command and insert its output |
| Variable | `DISK=88` | Store a value (no spaces around `=`) |
| Use a variable | `$DISK` | Get the stored value |
| Condition | `if [ "$DISK" -gt 80 ]; then ... else ... fi` | Make a decision; `fi` ends the `if` |

Comparison operators for numbers: `-gt` greater than, `-lt` less than, `-eq` equal.

The `.sh` extension means "shell script". The system does not require it, but it tells humans and editors what the file is. What actually makes it run is the shebang plus execute permission.

## 7. Git and GitHub

| Command | What it does |
|---|---|
| `git init` | Start tracking a folder as a Git project |
| `git status` | Show what changed and what is staged |
| `git add file` | Put a file in the staging area (the "box") |
| `git commit -m "message"` | Save a snapshot with a message |
| `git log --oneline` | Show the commit history in short form |
| `git remote add origin <url>` | Connect the local project to a GitHub repo |
| `git push -u origin main` | Upload commits; `-u` remembers the connection |
| `git push` | Upload new commits afterwards |

- **Git** keeps history on my computer. **GitHub** is the website that stores a copy online.
- `.gitignore` lists files Git should skip. I ignore `health.log` because it is generated output.
- Commit messages follow **conventional commits**: `feat:` new feature, `fix:` bug fix, `docs:` documentation, `chore:` maintenance.

---

# Errors I hit and what they taught me

| Error | Cause | Fix |
|---|---|---|
| `permission denied: ./health.sh` | File had no execute permission | `chmod +x health.sh` |
| `zsh: event not found: /bin/bash` | I typed the script in the terminal instead of the file; `!` is special in zsh | Write scripts in the editor, run commands in the terminal |
| `Data$: command not found` | The `grep` word was missing after the pipe, so the shell tried to run `Data$` as a command | Fix the typo: `df -h \| grep "Data$"` |
| `[: -gt: unary operator expected` | The variable `DISK` was empty inside the script; variables set in the terminal are not visible to a script | Create the variable inside the script, and quote it: `"$DISK"` |

Lesson: read the error message first. It usually names exactly what is wrong.

---

# Next steps

- Run the script automatically with `cron` and keep a history in `health.log`
- Check memory and top processes
- Add an app-level `/health` endpoint, then containerize everything with Docker
- Add a GitHub Actions workflow to lint the script on every push