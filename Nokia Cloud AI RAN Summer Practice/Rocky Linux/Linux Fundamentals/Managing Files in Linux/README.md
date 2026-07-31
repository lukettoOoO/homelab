# Chapter 3: Managing Files in Linux

## 1. Input/Output (I/O) Streams & Redirection

### Standard I/O Streams
In Linux, "everything is a file." Every process opens three standard file descriptors:
* **Standard Input (`stdin` / Descriptor `0`)**: Reads data input (keyboard or redirected file).
* **Standard Output (`stdout` / Descriptor `1`)**: Transmits normal program text output to the screen.
* **Standard Error (`stderr` / Descriptor `2`)**: Transmits error messages to the screen independently of standard output.

### Stream Redirection Syntax
* **Overwrite Output (`>`)**: Redirects `stdout` to a file, replacing its contents (`date > output.txt`).
* **Append Output (`>>`)**: Appends `stdout` to the end of an existing file (`date >> output.txt`).
* **Redirect Error (`2>`)**: Redirects `stderr` to a file (`ls /invalid 2> error.log`).
* **Discard Streams (`/dev/null`)**: Sends output or error streams to the kernel's virtual bit-bucket device (`command 2> /dev/null`).

### Command Pipelines (`|`)
* A **pipe (`|`)** connects the `stdout` of one command to the `stdin` of another (interprocess communication).
* **Piping Chains**: Multiple commands can be chained together (e.g., `timedatectl | grep 'time' | sort -b`).
* **`tee` Command**: Duplicates `stdout`, writing output to both the terminal screen and a target file simultaneously (`date | tee output.txt`).

---

## 2. Text vs. Binary Files & File Identification

### File Types
* **Text Files**: Encoded in human-readable character sets (ASCII, UTF-8). Contains source code, configuration files, scripts, and plain text documents.
* **Binary Files**: Contain structured machine data, executable code, compressed archives, or proprietary application formats (e.g., `.docx`, compiled executables).

### File Identification & Extensions
* Linux **does not rely on file extensions** (such as `.txt` or `.exe`) to determine file properties or execute binaries.
* **Magic Numbers**: Linux reads the file header (magic number) and compares it against a system database using the **`file`** command:
  * Compiled executables return **`ELF 64-bit`** (Executable and Linkable Format).
  * Text files return **`ASCII text`** or **`UTF-8 Unicode text`**.

### Hidden Files & Naming Rules
* **Hidden Files**: Filenames beginning with a dot (`.bashrc`, `.config`) store user settings and are hidden from standard directory listings. Use `ls -a` to display them.
* **Spaces in Filenames**: Whitespace acts as an argument separator in the shell. Handle filenames containing spaces by using:
  * Backslash escaping (`My\ File.txt`)
  * Quotation marks (`"My File.txt"` or `'My File.txt'`)
  * Tab completion.

---

## 3. Command-Line Text Utilities

### Directory Listing (`ls`)
* `ls`: Lists files and directories.
* `ls -l`: Long listing format showing permissions, link count, owner, group, file size, and timestamp.
* `ls -lh`: Displays file sizes in human-readable units (K, M, G).
* `ls -la`: Includes hidden files (names starting with `.`).
* `ls -lt`: Sorts output by modification time (newest first).

### Viewing Text Files
* `cat`: Displays the entire contents of text files to standard output.
* `less`: Paginated text viewer for large files. Navigation: `Up`/`Down` arrows to scroll, `/pattern` to search, `q` to quit.
* `head`: Displays the first 10 lines of a file (`head -n 5 file.txt` for 5 lines).
* `tail`: Displays the last 10 lines of a file (`tail -n 5 file.txt` for 5 lines).
* `wc`: Counts lines, words, and characters/bytes in a file (`-l` lines, `-w` words, `-c` bytes).

### Recovering Corrupted Terminals (`stty sane`)
Attempting to view binary files with text tools (`cat /bin/cat`) outputs raw binary control characters that can corrupt terminal display behavior.
* **Recovery Procedure**: Press `Ctrl + C` or `q`, press `Enter`, type **`stty sane`**, and press `Enter` to reset terminal settings.

---

## 4. Text Editors in Linux

### Graphical Text Editors
* **`gedit`**: Default GNOME graphical text editor. Supports syntax highlighting, line numbering, auto-indentation, and plugin extensions.

### Command-Line Text Editors

#### 1. `nano`
* Small, modeless text editor with shortcut keys displayed at the bottom of the screen.
* Common shortcuts:
  * `Ctrl + O`: Write out (save) file.
  * `Ctrl + X`: Exit editor.
  * `Ctrl + G`: Open help menu.
  * `Ctrl + \`: Search and replace.

#### 2. `vim`
* Advanced modal text editor for plain text, configuration files, and code.
* **Core Modes**:
  * **Command / Normal Mode** (Default): Used for navigation and file operations.
    * `i`: Switch to **Insert mode** (start editing text).
    * `Esc`: Return to **Command mode**.
    * `:w`: Save (write) changes.
    * `:q`: Quit editor.
    * `:q!`: Quit discarding unsaved changes.
    * `:w <filename>`: Save file with a specific name.
* **Learning Tool**: Run `vimtutor` from the terminal for interactive built-in lessons.
