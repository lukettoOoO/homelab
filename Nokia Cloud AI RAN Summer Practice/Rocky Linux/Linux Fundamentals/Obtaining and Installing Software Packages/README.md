# Chapter 6: Obtaining and Installing Software Packages

## 1. Software Distribution & RPM Packaging

### Source Code vs. Prebuilt Packages
* **Source Code Compilation**: Compiling software directly from source requires development tools, dependencies, and significant compilation time. Re-compiling for security patches increases administrative burden.
* **Prebuilt Packages**: Linux software is distributed as pre-compiled binary packages that are fast, consistent, and easy to deploy.

### Red Hat Package Manager (RPM) & Repositories
* **RPM Format**: Standard package format used by Red Hat Enterprise Linux, Rocky Linux, Fedora, and CentOS. An RPM package is a compressed, cryptographically signed archive containing program binaries, configuration files, and installation metadata.
* **Repositories**: Centralized online locations hosting RPM packages. Package managers connect to repositories over network protocols, resolve dependencies automatically, deploy files to system paths, and log software state in a local database.

---

## 2. Package Management Tools

### Graphical Package Management (GNOME Software)
Front-end interface for system repositories and Flatpaks:
* **Explore Tab**: Browse applications by category (e.g., Development, Utilities, Work).
* **Installed Tab**: View installed desktop applications and remove software without terminal commands.
* **Updates Tab**: Display available application updates and trigger system update workflows.

### Command-Line Package Management (`dnf`)
DNF (Dandified YUM) is the default command-line package manager for RHEL/Rocky Linux. Software installed via `dnf` is deployed system-wide and requires `sudo` privileges.

#### Essential `dnf` Commands
* `dnf repolist`: Lists all enabled software repositories.
* `dnf search <keyword>`: Searches repositories for package names or descriptions.
* `dnf info <package>`: Displays package version, size, source repo, architecture, and description.
* `dnf list installed [package]`: Checks if a specific package is installed locally.
* `sudo dnf install <package1> [package2]`: Installs target packages along with their required dependencies.
* `dnf history`: Displays past package installation, update, and removal transactions.

---

## 3. Sandboxed Application Distribution (Flatpak)

### Flatpak Architecture
Flatpak packages desktop applications inside isolated Linux containers, bundling required libraries independent of the core host system.

### Key Benefits
* **No `sudo` Required**: Non-administrative users can safely install desktop applications without requiring root privileges.
* **Flathub**: The primary centralized open-source repository for Flatpak applications (`flathub.org`).

#### Flatpak CLI Operations
* Install Flatpak engine: `sudo dnf install flatpak`
* Add Flathub repository:  
  `flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo`
* List configured repositories: `flatpak remotes`

---

## 4. Archiving & Data Compression

Archives consolidate multiple files and directory structures into a single file. Compression algorithms reduce total storage size.

### Standard Formats & Extensions
* **`.tar`**: Uncompressed Tape Archive (tarball).
* **`.tar.gz` / `.tgz`**: Tarball compressed with `gzip`.
* **`.tar.xz`**: Tarball compressed with `xz` (higher compression ratio).
* **`.zip` / `.7z`**: Common archive formats supporting optional password protection.

### Command-Line Archiving (`tar` & `unzip`)

#### Primary `tar` Options
* `-c` (`--create`): Create a new archive.
* `-x` (`--extract`): Extract contents from an archive.
* `-t` (`--list`): View contents of an archive without extracting.
* `-f` (`--file`): Specify the archive file name.
* `-z` (`--gzip`): Filter archive through `gzip` (`.tar.gz`).
* `-J` (`--xz`): Filter archive through `xz` (`.tar.xz`).
* `-C` (`--directory`): Change to destination directory before extracting.

#### Common `tar` Command Examples
* **Create compressed archive**:  
  `tar -czf archive.tar.gz /path/to/directory`  
  `tar -cJf archive.tar.xz /path/to/directory`
* **List archive contents**:  
  `tar -tf archive.tar.gz`
* **Extract archive to current directory**:  
  `tar -xzf archive.tar.gz`
* **Extract archive to specific directory**:  
  `tar -xzf archive.tar.gz -C /tmp/backup`
* **Extract a single file from archive**:  
  `tar -xzf archive.tar.gz directory/specific_file.txt`

#### Extracting ZIP Files
* `unzip archive.zip`: Extracts `.zip` archive contents into the current working directory.
