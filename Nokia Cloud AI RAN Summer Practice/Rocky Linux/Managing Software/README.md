# Managing and Installing Software in Rocky Linux / RHEL

## 1. Overview of Software Distribution

Linux software is distributed using two primary methods:
* **Precompiled Binary Packages**: Software packaged as compiled binaries, libraries, and metadata. Easy to install and manage, but least customizable.
* **Source Code Archives**: Human-readable source files (typically C or C++) packaged in compressed tarballs (`.tar.gz`, `.tar.xz`, `.tar.bz2`). Allows custom compilation flags and modular feature control, but requires build tools and manual dependency management.

---

## 2. Low-Level Package Management with RPM

The **Red Hat Package Manager (RPM)** is the low-level utility and database standard for managing software on RHEL-based distributions (Rocky Linux, Fedora, RHEL). Package files carry the `.rpm` extension.

### Package Naming Conventions
* **Full Package File Name**: Used when operating on uninstalled local `.rpm` files.
  * Structure: `[Name]-[Version]-[Release].[OS].[Arch].rpm`
  * Example: `wget-1.19.5-10.el8.x86_64.rpm`
* **Installed Package Name**: Used when operating on packages registered in the system RPM database.
  * Example: `wget`, `bash`, `NetworkManager`

### Querying Packages (`rpm -q`)
To query local files, append the `-p` (package) flag.

* **List Installed Packages**: `rpm -qa`
* **Package Metadata**: `rpm -qi <package>` (or `rpm -qip <file.rpm>`)
* **List Files Included in Package**: `rpm -ql <package>` (or `rpm -qlp <file.rpm>`)
* **Specific Query Formats**: `rpm -q --queryformat '%{version} %{summary}\n' <package>`
* **Query Special Files**:
  * Configuration files: `rpm -qc <package>`
  * Documentation files: `rpm -qd <package>`
  * License files: `rpm -qL <package>`

### Package Operations & Dependency Handling
* **Install**: `rpm -ivh <file.rpm>` (`-i` install, `-v` verbose, `-h` print hash progress bar)
* **Upgrade**: `rpm -Uvh <file.rpm>` (upgrades existing package or installs if missing)
* **Uninstall**: `rpm -e <package_name>`
* **Dependency Limitations**: RPM checks dependencies recorded in package metadata but **cannot automatically download or resolve missing prerequisites**. If a dependency fails, RPM halts installation.
* **Bypassing Checks**: `--nodeps` forces installation or removal without verifying dependencies. *Caution*: Using `--nodeps` can break installed packages or render applications unusable.

### Package Verification & Integrity
* **Signature & Digest Check**: Verifies cryptographic signatures and file integrity before installation:  
  `rpm -K <file.rpm>` (Returns `digests signatures OK` or `DIGESTS SIGNATURES NOT OK` if corrupted/altered).
* **Import GPG Public Key**:  
  `sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial`
* **File Verification (`rpm -V`)**: Compares installed package files against the RPM database.
  * Syntax: `rpm -V <package>`
  * **Status Character Output (9 Fields)**:
    * `S`: File size altered
    * `M`: File permissions/mode altered
    * `5`: MD5 / Checksum altered
    * `D`: Device major/minor number mismatch
    * `L`: Symlink path mismatch
    * `U`: User ownership changed
    * `G`: Group ownership changed
    * `T`: Modification time (`mtime`) changed
    * `P`: Capabilities altered
  * **File Type Identifiers**: `c` (config file), `d` (documentation file), `l` (license file), `r` (readme file).

---

## 3. High-Level Package Management with DNF

**DNF (Dandified YUM)** is the high-level package management tool in Rocky Linux 8/9 and RHEL. DNF acts as a wrapper around the RPM database, automatically resolving package dependencies and querying online software repositories.

### Primary DNF Operations
* **Download Package Files**: `dnf download <package>` (or `dnf download --arch x86_64 <package>`)
* **Find Dependency Provider**: `dnf whatprovides <library_or_filename>` (e.g., `dnf whatprovides libmetalink.so.3`)
* **Install Package**: `sudo dnf install <package>` (`-y` flag automatically confirms prompts)
* **Remove Package**: `sudo dnf remove <package>` (removes package and associated orphaned dependencies)
* **Package Groups**:
  * List groups: `dnf group list`
  * Group details: `dnf group info "Development Tools"`
  * Install group: `sudo dnf group install "Development Tools"`
* **System Updates**:
  * Check for updates: `dnf check-update`
  * Check security updates: `dnf --security check-update`
  * Apply updates: `sudo dnf upgrade`

---

## 4. Building Software from Source Code

Compiling software from source code allows custom installation paths, selective feature configuration, and optimization for targeted system environments.

### Required Toolchain
Building C/C++ software requires the `Development Tools` environment group (includes `gcc`, `g++`, `make`, `autoconf`, and `automake`).

### Build Workflow Steps

#### 1. Unpacking the Source Archive
Extract the tarball containing the source code:  
`tar -xvzf package-version.tar.gz`

#### 2. Configuration (`./configure`)
Run the configuration script inside the extracted source directory to check system libraries, detect compilers, set build flags, and generate the `Makefile`.
* View configurable features: `./configure --help`
* Common flag: `--prefix=/path` (specifies target installation directory; defaults to `/usr/local` if omitted).
* Run configuration: `./configure`

#### 3. Compilation (`make`)
Executes the build instructions defined in `Makefile`. Compiles source text files into object files and links them into binary executables.  
`make`

#### 4. Installation (`sudo make install`)
Copies compiled binaries, shared libraries, headers, and documentation into the designated prefix paths (e.g., `/usr/local/bin`, `/usr/local/share/man`).  
`sudo make install`
