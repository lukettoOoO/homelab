# Chapter 4: File Systems Overview

## 1. Linux File System Hierarchy & Navigation

### File System Architecture
All files and directories in Linux exist under the **root directory (`/`)**.
* **Three Meanings of "Root"**:
  1. **`/` (Root Directory)**: The top-level starting point of the entire file system tree.
  2. **`root` User**: The administrative superuser account.
  3. **`/root` Directory**: The personal home directory of the `root` user.

### Core System Directories
* **`/home`**: Contains individual user home directories (e.g., `/home/username`). Prepopulated with standard folders (`Desktop`, `Documents`, `Downloads`, `Music`, `Pictures`, `Public`, `Templates`, `Videos`).
* **`/etc`**: System configuration files.
* **`/tmp`**: Temporary files created by system and applications (automatically purged periodically).
* **`/usr`**: Installed applications, system utilities, and libraries.
* **`/var`**: Variable system data that persists between boots (log files, databases, spools).

### Path Definitions
* **Absolute Path**: Explicit path starting from the root directory (`/`). Always begins with a leading `/` (e.g., `/home/user/Documents/notes.txt`).
* **Relative Path**: Path relative to the current working directory. Never begins with a leading `/`.
  * **`.` (Single Dot)**: Represents the current working directory.
  * **`..` (Double Dot)**: Represents the parent directory.

### Navigation & Discovery Commands
* `pwd`: Prints the absolute path of the current working directory.
* `cd`: Changes working directory (`cd` with no arguments returns to the user's home directory).
* `realpath`: Resolves and prints the absolute path of a relative path or target file.
* `tree`: Displays directory contents in a recursive tree structure (`-L <depth>` limits display depth).

---

## 2. File & Directory Manipulation

### Creation & Modification
* **`mkdir`**: Creates directories (`-p` creates parent directories in the specified path if they do not exist).
* **`touch`**: Creates an empty file or updates the access/modification timestamp of an existing file.
* **`cp`**: Copies files (`cp source target`). Use `-r` or `--recursive` to copy directories and their contents.
* **`mv`**: Moves files/directories or renames them in-place (`mv old_name new_name`).

### Shortcuts & Symbolic Links
* **Symbolic Link (Symlink)**: A pointer file referencing another file or directory.
  * Syntax: `ln -s /path/to/target link_name`
  * Deleting a symlink removes the shortcut, leaving the original target file intact.

### File Deletion & Trash Mechanics
* **`rm`**: Permanently removes files from the file system. **Caution**: `rm` bypasses any trash mechanism and cannot be easily undone.
* **Desktop Trash Directory**: Desktop soft-deletions store files in `~/.local/share/Trash/files`. Moving a file here via `mv` allows recoverable deletion.

### Searching Files (`find`)
* `find [path] -iname "pattern"`: Recursively searches directories for filenames matching a pattern (case-insensitive).
* Separate stdout and stderr during searches via redirection:
  `find /home/user -iname "*.txt" 1> results.txt 2> errors.log`

---

## 3. Batch Processing & Globbing (Wildcards)

Globbing allows the shell to interpret metacharacters as placeholders to match multiple files in a single command.

### Key Shell Metacharacters
* **`~` (Tilde)**: Expands to the current user's home directory path (`/home/username`).
* **`*` (Asterisk)**: Matches zero or more characters (e.g., `*.pdf` matches all PDF files).
* **`?` (Question Mark)**: Matches exactly one character (e.g., `file?.txt` matches `file1.txt`, but not `file10.txt`).

### Preventing Expansion (Escaping)
To treat a metacharacter or whitespace literally, use the backslash (`\`) escape character:
* `ls ex\*mple.txt`: Treats `*` as a literal character.
* `ls My\ File.txt`: Escapes the space character to prevent shell argument splitting.

---

## 4. Storage Space Management

### Disk Usage Considerations
Running out of storage space on a system drive can prevent system logging, disrupt service execution, and block user authentication.

### Storage Monitoring Commands
* **`df -h` (Disk Free)**: Displays summary statistics for mounted file systems (total size, used space, available space, percentage used, and mount point) in human-readable format (K, M, G).
* **`du -h` (Disk Usage)**: Displays detailed disk space usage for directories and their contents recursively (`du -sh ~` shows total home directory usage summary).
* **Disk Usage Analyzer (`baobab`)**: Graphical tool displaying hierarchical ring charts of disk consumption across directories.
