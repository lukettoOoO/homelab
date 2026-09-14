## 1. Remote Access & Navigation

- **`ssh`** `[00:00:04]` – Secure shell connection to a remote Linux machine (`ssh username@host_ip`).
- **`ls`** `[00:00:16]` – Lists directory contents.
  - `ls -l` – Detailed list view (permissions, file size, owner).
  - `ls -a` – Includes hidden files.
- **`pwd`** `[00:00:26]` – (*Print Working Directory*) Displays your current full directory path.
- **`cd`** `[00:00:31]` – (*Change Directory*) Navigates between folders.
  - `cd /` – Move to the root directory.
  - `cd ..` – Move up one directory level.
  - `cd` – Return to the user's home directory.
- **`clear`** `[00:02:44]` – Clears the terminal screen.

---

## 2. File Creation, Editing & Manipulation

- **`touch`** `[00:00:49]` – Creates empty files or updates file timestamps.
  - Can create multiple files at once (`touch f1 f2`).
  - `touch -d "date"` – Set a specific creation/modification timestamp.
- **`echo`** `[00:01:21]` – Prints text or redirects output to a file (`echo "text" > file.txt`).
- **`nano`** `[00:01:30]` – Beginner-friendly terminal text editor (save: `Ctrl + X`, `Y`, `Enter`).
- **`vim`** `[00:01:38]` – Powerful modal text editor (`i` for insert mode, `Esc` then `:wq` to write and quit).
- **`cat`** `[00:01:55]` – Concatenates and prints full file contents to standard output.
- **`shred`** `[00:02:00]` – Overwrites and securely deletes a file to prevent recovery.
- **`mkdir`** `[00:02:10]` – (*Make Directory*) Creates a new directory.
- **`cp`** `[00:02:10]` – Copies files or directories (`cp source destination`).
- **`mv`** `[00:02:15]` – Moves or renames files and directories (`mv source destination`).
- **`rm`** `[00:02:23]` – Removes files (`rm -r` for recursive directory deletion).
- **`rmdir`** `[00:02:28]` – Removes empty directories.
- **`ln`** `[00:02:33]` – Creates file links (`ln -s source link` for symbolic/soft links).

---

## 3. Users, Permissions & Privileges

- **`whoami`** `[00:02:48]` – Prints the currently logged-in username.
- **`sudo`** `[00:02:57]` – Executes commands with superuser/root administrative privileges.
- **`useradd` / `adduser`** `[00:02:57]` – Adds a new user to the system.
- **`su`** `[00:03:13]` – (*Switch User*) Switches user session (`su <username>`).
- **`exit`** `[00:03:17]` – Exits current user session, sub-shell, or SSH session.
- **`passwd`** `[00:03:26]` – Changes user passwords (`sudo passwd <user>`).
- **`finger`** `[00:03:45]` – Displays detailed user account information.
- **`chmod`** `[00:06:11]` – Changes file mode/permissions (e.g., `chmod +x script.sh`).
- **`chown`** `[00:06:23]` – Changes file owner and group (`chown user file`).

---

## 4. Package Management & Manuals

- **`apt`** `[00:03:49]` – Package manager for Debian/Ubuntu-based systems (`sudo apt update`, `sudo apt install pkg`).
- **`yum`** `[00:04:00]` – Package manager for Red Hat / CentOS systems.
- **`man`** `[00:04:14]` – (*Manual*) Opens reference manual pages for any command (`man <command>`).
- **`whatis`** `[00:04:34]` – Displays single-line manual page descriptions.
- **`which`** `[00:04:39]` – Locates the executable binary file of a command.
- **`whereis`** `[00:04:42]` – Locates binary, source code, and manual page files for a command.

---

## 5. Networking & Web Downloads

- **`wget`** `[00:04:42]` – Non-interactive network downloader via HTTP/HTTPS/FTP.
- **`curl`** `[00:04:52]` – Transfers data to/from servers across multiple network protocols.
- **`ifconfig`** `[00:06:34]` – (*Legacy*) Configures and displays network interface parameters.
- **`ip address` / `ip a`** `[00:06:40]` – Modern standard tool to inspect and configure IP addresses.
- **`/etc/resolv.conf` / `resolvectl status`** `[00:07:11]` – Inspects DNS nameserver configuration.
- **`ping`** `[00:07:28]` – Sends ICMP ECHO_REQUEST packets to test network reachability (`ping -c 5 host`).
- **`traceroute`** `[00:07:44]` – Traces network packet routes and hop latency to a target host.
- **`netstat`** `[00:07:54]` – Displays network connections, routing tables, and interface stats (`netstat -tulnp`).
- **`ss`** `[00:08:04]` – Modern, fast socket statistics utility (replaces `netstat`).
- **`ufw`** `[00:08:16]` – (*Uncomplicated Firewall*) Program for managing a netfilter firewall (`ufw allow 80`, `ufw enable`).

---

## 6. Text Processing, Archives & Search

- **`zip`** `[00:05:02]` – Packages and compresses files into `.zip` archives.
- **`unzip`** `[00:05:12]` – Extracts compressed `.zip` archives.
- **`less`** `[00:05:17]` – Interactive text viewer with backward and forward screen navigation.
- **`head`** `[00:05:27]` – Outputs the beginning lines of a file (default: 10 lines).
- **`tail`** `[00:05:31]` – Outputs the last lines of a file.
- **`cmp`** `[00:05:31]` – Compares two files byte-by-byte and reports discrepancies.
- **`diff`** `[00:05:42]` – Compares files line-by-line and details exact content differences.
- **`sort`** `[00:05:45]` – Sorts lines of text files alphabetically or numerically.
- **`find`** `[00:05:56]` – Searches directory hierarchies recursively matching filters and criteria.
- **`grep`** `[00:06:45]` – Searches text patterns using regular expressions via files or pipelines (`|`).
- **`awk`** `[00:07:02]` – Pattern scanning and processing language for advanced column manipulation.

---

## 7. System Monitoring, Processes & Power

- **`uname`** `[00:08:44]` – Prints system and OS kernel information (`uname -a`).
- **`neofetch`** `[00:08:49]` – CLI system information tool displaying distro logos and hardware specs.
- **`cal` / `ncal`** `[00:08:55]` – Displays a simple terminal calendar.
- **`bc`** `[00:09:05]` – Command-line arbitrary-precision calculator.
- **`free`** `[00:09:13]` – Displays total amount of free and used physical memory (RAM) and swap.
- **`df`** `[00:09:21]` – (*Disk Free*) Displays file system disk space usage (`df -h` for human-readable output).
- **`ps`** `[00:09:26]` – Reports a snapshot of currently running processes (`ps aux`).
- **`top`** `[00:09:36]` – Real-time dynamic view of active system processes and resource consumption.
- **`htop`** `[00:09:40]` – Interactive process viewer and enhanced alternative to `top`.
- **`kill`** `[00:09:45]` – Terminates processes via signal transmission and Process ID (`kill -9 <PID>`).
- **`pkill`** `[00:10:02]` – Sends signals to processes based on matching name/pattern (`pkill -f <name>`).
- **`systemctl`** `[00:10:11]` – Controls systemd system and service manager (`start`, `stop`, `restart`, `status`).
- **`history`** `[00:10:27]` – Displays previously entered command history.
- **`reboot`** `[00:10:31]` – Restarts the operating system (`sudo reboot`).
- **`shutdown`** `[00:10:38]` – Halts/powers down the machine (`sudo shutdown -h now`).