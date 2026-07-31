# Chapter 1: Introduction to Linux & Linux Distributions

## 1. What is Linux?
* **Kernel vs. Operating System**: Strictly speaking, Linux is just the **kernel**, not the complete operating system.
  * The kernel is software responsible for booting the system, managing memory, handling processes, and loading hardware drivers (keyboard, display, storage, etc.).
* **History & Licensing**:
  * Started by Linus Torvalds in 1991.
  * Released under the **GNU General Public License (GPL)**, ensuring code can be freely used, modified, and shared, provided public modifications are contributed back.
  * The term "open source" was coined in 1998 by Christine Peterson.
  * Combining the Linux kernel with applications from the GNU (Gnu's Not UNIX) project created a functional, UNIX-like operating system running on commodity hardware.
* **Modern Ecosystem**: Widely deployed across cloud infrastructure, enterprise servers, desktop/laptop computers, and consumer devices (Android, Chromebooks, Steam Deck).

---

## 2. Boot Process & Interfaces

### System Boot Sequence
1. **Firmware**: Computer motherboard firmware locates the boot loader on the storage drive.
2. **Boot Loader**: Loads the operating system code into memory and executes it.
3. **Kernel Initialization**: Kernel loads into memory, probes hardware, and loads appropriate device drivers.
4. **Service Manager**: Launches background services (networking, graphics, audio, desktop display manager / login prompt).

### User Interfaces
* **Graphical User Interface (GUI)**: Point-and-click interface represented by visual icons, windows, and desktop layouts (e.g., GNOME).
* **Shell / Terminal / Console**: Text-only command prompt. Highly efficient, easily automated/scriptable, and faster over network connections.

---

## 3. Overview of Linux Distributions

A **distribution** (distro) is a complete operating system build that combines the Linux kernel with system software, libraries, package management, and applications tailored for a specific purpose.

### Common Distributions
* **Red Hat Enterprise Linux (RHEL)**: Enterprise-grade distribution focused on stability, security, and long-term support.
* **Fedora**: Community distribution focused on rapid release cycles and introducing cutting-edge features.
* **CentOS**: Community-driven development platform for Red Hat Enterprise Linux.
* **Debian**: Community project prioritizing system stability and long-term support; base for many derivative distros.
* **Universal Base Image (UBI)**: Minimalist container image optimized for cloud services without unnecessary hardware drivers.
* **Raspberry Pi OS**: Lightweight distribution optimized for low-power embedded hardware.

### Distribution Pipeline
`Fedora (Upstream / Newest Features) --> CentOS (Development Platform) --> RHEL (Production / Long-Term Support)`

---

## 4. Identifying Distribution Details

System distribution and hardware specifications can be identified through the graphical desktop interface:

* **GNOME Settings**: Navigating to `Activities` -> `Settings` -> `About` displays system properties including OS Name, kernel version, GNOME version, installed RAM, processor, and available storage.
