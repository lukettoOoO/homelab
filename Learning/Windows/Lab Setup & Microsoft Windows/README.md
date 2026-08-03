# Lab Setup & Windows Fundamentals

---

## 1. Lab Setup Overview

### Provisioning Options
1. **Physical Machine (Bare-Metal)**:
   * Direct installation on physical hardware.
   * Requires formatting/overwriting existing operating systems.
2. **Virtual Machine (Recommended)**:
   * Host OS runs VirtualBox (Hypervisor).
   * Guest OS (Windows VM) runs isolated within VirtualBox.

---

## 2. Fundamentals of Operating Systems

### What is an Operating System?
An **Operating System (OS)** acts as an intermediary (middleman) between physical hardware components and the end-user/applications.

```
+-------------------------------------------------------+
|                       User / Apps                     |
+-------------------------------------------------------+
|                    Operating System                   |
|          (Kernel, Drivers, GUI / CLI Shell)           |
+-------------------------------------------------------+
|                     Physical Hardware                 |
|            (CPU, RAM, Hard Disk, Peripherals)         |
+-------------------------------------------------------+
```

### OS Functions
* **Hardware Interaction**: Communicates instructions from peripherals (keyboard, mouse) to hardware components (CPU, storage, printers, network adapters).
* **Execution Environment**: Runs user programs and manages processes.
* **Network & I/O Routing**: Handles internet traffic, file storage, and device I/O.

---

## 3. Microsoft & Windows History

### History & Background
* **Founding**: Microsoft was co-founded by **Bill Gates** and **Paul Allen** on **April 4, 1975**.
* **MS-DOS**: Microsoft's first operating system was command-line based (Disk Operating System). Command prompt (`cmd`) remains available in modern Windows systems.
* **GUI Innovation**: Windows introduced a Graphical User Interface (GUI) over DOS, making computing accessible to non-technical users via point-and-click navigation.

### Key Microsoft Products & Services
* **Operating Systems**: Windows Desktop, Windows Server, Windows Phone.
* **Productivity Suites**: Microsoft Office (Word, Excel, PowerPoint).
* **Cloud Platform**: **Microsoft Azure** (Infrastructure/Platform as a Service for compute, storage, and networking).
* **Databases**: **Microsoft SQL Server** (Relational Database Management System).
* **Enterprise Communications & Directory**:
  * **Active Directory (AD)**: Centralized user, identity, and domain management.
  * **Microsoft Exchange**: Enterprise mail and scheduling server.
  * **Skype / Teams**: Communications platform.
* **Collaboration & Design Tools**: SharePoint, Microsoft Visio.
* **Hardware & Gaming**: Surface laptops/tablets, Xbox gaming consoles.

---

## 4. Windows Operating System Timeline

### Desktop Versions
| Version | Release Date / Era | Key Notes |
| :--- | :--- | :--- |
| **Windows 1.01** | Nov 20, 1985 | Initial GUI release. |
| **Windows NT 3.5** | 1995 | Major architecture improvements and enterprise features. |
| **Windows 98** | 1998 | Popular consumer OS release. |
| **Windows 2000 / ME** | 2000 | Windows 2000 for business; ME for handhelds/consumers. |
| **Windows XP** | 2001 | Massive adoption; highly stable consumer/business OS. |
| **Windows Vista** | 2006 | Introduced new UI features, but suffered performance issues. |
| **Windows 7** | 2009 | Highly acclaimed, widely adopted, and long-lasting desktop OS. |
| **Windows 8 / 8.1** | 2012 | Introduced tile-based UI (Metro interface). |
| **Windows 10** | July 29, 2015 | Unified platform with frequent feature updates. |

### Server Versions
| Version | Release Date / Era | Key Notes |
| :--- | :--- | :--- |
| **Windows NT Server** | August 1993 | First NT server OS. |
| **Windows Server 2000** | 2000 | Introduced Active Directory. |
| **Windows Server 2003 / R2** | 2003 | Major enhancements to Active Directory, DNS, and Exchange support. |
| **Windows Server 2008 / R2** | 2008 / 2009 | Introduced Hyper-V and Server Core. |
| **Windows Server 2012 / R2** | 2012 | Enhanced cloud integration and IPAM. |
| **Windows Server 2016** | 2016 | Modern container support and UI parity with Windows 10. |
| **Windows Server 2019+** | 2018+ | Hybrid cloud integration with Azure. |

---

## 5. Operating System Comparison: Windows vs. Mac vs. Linux

### Comparison Matrix

| Feature | Windows | macOS (Apple) | Linux |
| :--- | :--- | :--- | :--- |
| **Primary Focus** | General computing, enterprise, gaming | Creative design, media, ecosystem integration | Servers, cloud, enterprise, dev environments |
| **Cost** | Commercial (Paid license) | Included with Apple hardware | Free & Open Source (FOSS) |
| **Market Share (Desktop)** | ~90%+ | ~6% - 10% | ~2% - 3% |
| **Market Share (Server)** | Secondary | Negligible | Dominant (Cloud / Enterprise) |
| **Hardware Flexibility** | High (Runs on vendor hardware) | Proprietary (Apple hardware only) | Very High (Runs on almost any hardware) |
| **User Interface** | GUI + CLI (`cmd` / PowerShell) | GUI (macOS) + Unix Shell (zsh/bash) | CLI-first / GUI options (Ubuntu, Fedora) |

### Pros & Cons Summary

#### Windows
* **Pros**: Broad software/game/driver compatibility, massive global community support, intuitive GUI.
* **Cons**: Vulnerable to malware/viruses, OS licensing fees, resource overhead over time.

#### macOS
* **Pros**: Low malware surface area, optimized hardware/software performance, industry standard for media and graphic design.
* **Cons**: High hardware entry cost, locked to Apple hardware, lower gaming & third-party software availability.

#### Linux
* **Pros**: 100% free and open-source, lightweight, security-hardened, customisable source code.
* **Cons**: Steeper learning curve (CLI-heavy), limited commercial desktop software/gaming support out-of-the-box.
