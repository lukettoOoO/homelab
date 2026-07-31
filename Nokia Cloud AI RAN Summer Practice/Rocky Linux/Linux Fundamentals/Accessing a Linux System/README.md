# Chapter 2: Accessing a Linux System

## 1. User Management & Security Principles

### Multiuser Architecture
* **Isolation & Privacy**: Linux supports multiple concurrent users. Each user has a unique login account and an isolated home directory.
* **Separation of Duties**: Standard users cannot modify system configuration files, protecting data integrity and preventing unintended global changes.

### Account Types
* **Root Account (`root`)**:
  * Superuser / administrator account with unrestricted access to all system resources, files, and configuration.
  * **Security Rule**: Avoid using `root` for daily operations to prevent accidental system destruction or security compromises. Many distributions lock direct `root` logins by default.
* **Standard (Unprivileged) Accounts**:
  * Accounts created for regular daily usage.
  * Restricted to changing personal configuration within their home directory.
  * Granted selective administrative rights via privilege escalation tools when needed.

---

## 2. System Access Environments

### 1. Linux Console (TTY)
* Physical or virtual display device outputting text-only prompts.
* Default fallback when no graphical desktop environment is installed.
* Minimal bandwidth usage makes text consoles ideal for remote management over slow networks.

### 2. GNOME Graphical Desktop Manager (GDM)
* System service managing graphical authentication and login sessions.
* **GNOME Desktop Layout**:
  * **Activities Overview** (Top-Left / `Super` Key): Manages windows and launches applications.
  * **System Menu** (Top-Right): Quick access to network, volume, power options, and settings.
  * **Dash / Taskbar** (Bottom Panel): Hosts favorite app launchers and grid view for installed applications.

### 3. Cockpit (Web-Based Console)
* Browser-based administration tool sponsored by Red Hat.
* Access URL: `https://localhost:9090` (uses port `9090` with self-signed SSL certificate by default).
* Allows administrators to monitor system performance, inspect logs, manage user accounts, and update system configuration over standard HTTP/HTTPS.

---

## 3. Virtual Consoles & Shell Access

### Virtual Consoles (TTY Switching)
Linux provides multiple independent virtual consoles running in memory:
* `TTY1`: Runs GNOME Display Manager (GDM login screen).
* `TTY2`: Hosts active GNOME graphical desktop session.
* `TTY3` – `TTY6`: Text-only virtual consoles accessible via keyboard shortcuts:
  * Switch to text console: `Ctrl + Alt + F3` (or `F4`–`F6`).
  * Return to graphical session: `Ctrl + Alt + F2`.
  * Return to GDM login screen: `Ctrl + Alt + F1`.
* **Important**: Console sessions do not automatically lock upon inactivity. Always end sessions with `exit` or `Ctrl + D`.

### Terminal Emulators & Shells
* **Terminal**: Desktop application that emulates a hardware TTY inside the graphical environment without requiring a separate login.
* **Shell (Bash)**: Command interpreter program running inside terminals and consoles. Translates user commands into kernel requests, provides PATH resolution, tab completion, and scripting support.

---

## 4. Command Line Mechanics & Basic Utilities

### Command Syntax Structure
`command [options] [arguments]`

* **Command**: Name of program/builtin being executed (searched via system `$PATH`).
* **Options**: Modifies behavior. Short format uses `-o`; long format uses `--option`.
* **Arguments**: Target object (file, username, host) acted upon by the command.

### Essential System Queries
* `hostname`: Displays machine network hostname (`-s` for short name, `-d` for domain name).
* `hostnamectl`: Shows detailed OS, kernel version, architecture, virtualisation type, and machine IDs.
* `id`: Displays user ID (`uid`), primary group (`gid`), and supplementary groups (`-u` to output only UID).
* `who`: Lists currently logged-in users and their active terminal devices.
* `date`: Prints current system date and time.
* `timedatectl`: Shows local time, UTC, time zone, RTC clock status, and NTP synchronization status.
* `passwd`: Modifies user account password (regular user changes own password; `root` can target any account).

### Shell Efficiency: Tab Completion
* Press **`Tab`** once: Auto-completes a unique command or file path.
* Press **`Tab` twice**: Lists all possible matching commands or file paths if the input is ambiguous.
