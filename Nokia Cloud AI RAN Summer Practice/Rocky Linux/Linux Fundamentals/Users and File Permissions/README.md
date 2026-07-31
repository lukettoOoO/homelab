# Chapter 5: Users and File Permissions

## 1. User Accounts, Groups & Ownership

### User Accounts & Identifiers
Linux controls resource access through authentication and numeric IDs:
* **User Identifier (UID)**: Unique numerical identifier assigned to every account.
  * **System Users (`UID < 1000`)**: Accounts created by the OS to run background services and daemons securely without administrative login capabilities.
  * **Standard Users (`UID >= 1000`)**: Regular user accounts (the first unprivileged user created during installation typically gets `UID 1000`).

### User Groups & Group Identifiers (GID)
* **Primary Group**: Created automatically when a user account is provisioned (shares the same name and GID as the UID).
* **Secondary / Supplementary Groups**: Additional groups assigned to a user to grant shared file access across teams.
* **Group Inspection Commands**:
  * `id [username]`: Displays UID, primary GID, and all supplementary group memberships.
  * `id -g --name [username]`: Displays the primary group name.
  * `groups [username]`: Lists all groups associated with the specified account.

### File & Directory Ownership
Every file and directory in Linux has two owners:
1. **User Owner**: The individual account that owns the file.
2. **Group Owner**: The group that owns the file (all members of this group inherit group-level access permissions).

#### Modifying Ownership (`chown`)
* View ownership: `ls -l` (displays user owner in column 3, group owner in column 4).
* Change user owner: `chown newuser file`
* Change group owner: `chown :newgroup file`
* Change user and group owner: `chown newuser:newgroup file`
* Recursive modification: `chown -R user:group directory/`

---

## 2. Privilege Escalation (`sudo`)

### Principle of Least Privilege
Standard accounts are restricted from modifying system-wide settings, installing software, or accessing files owned by other users. This prevents accidental system corruption or unauthorized access.

### Superuser Do (`sudo`)
* **`sudo`**: Enables authorized standard users to execute specific commands with administrative (`root`) privileges.
* **Execution**: Prefix commands requiring elevated rights with `sudo` (`sudo chown :sales-team /Finance`). The user is prompted for their own account password to authenticate.
* **List Privileges**: `sudo -l` displays the specific administrative commands the current user is permitted to execute via `sudo`.

---

## 3. Linux File Permissions Model

### Target User Categories
Permissions are divided into three distinct target categories:
1. **User / Owner (`u`)**: The specific user account owning the file.
2. **Group (`g`)**: Members of the group owning the file.
3. **Others (`o`)**: All other system users not covered by user or group sets.

### Permission Types
| Permission | Symbol | File Meaning | Directory Meaning | Octal Value |
| :--- | :---: | :--- | :--- | :---: |
| **Read** | `r` | View file contents | List directory contents (`ls`) | `4` |
| **Write** | `w` | Modify or overwrite file contents | Create, delete, or rename files in the directory | `2` |
| **Execute** | `x` | Run file as a binary or script | Traverse/enter directory (`cd`) | `1` |

---

## 4. Permission Representation & Modification

### Permission Representations

#### 1. Symbolic String Representation (`rwxrwxrwx`)
Displayed in the first column of `ls -l` (10 characters: 1 file type indicator + 9 permission bits):
* **Characters 1–3**: User permissions (`rwx`)
* **Characters 4–6**: Group permissions (`rw-`)
* **Characters 7–9**: Others permissions (`r--`)
* *Example*: `-rwxr-x---` (Regular file: User has `rwx`, Group has `r-x`, Others have `---`).

#### 2. Octal Notation Representation
File permissions are represented by 3 digits (or 4 digits with a leading `0` for no special bits):
* **`7`** = `4 + 2 + 1` (`rwx` — Read, Write, Execute)
* **`6`** = `4 + 2` (`rw-` — Read, Write)
* **`5`** = `4 + 1` (`r-x` — Read, Execute)
* **`4`** = `4` (`r--` — Read Only)
* **`0`** = `---` (No Permissions)

*Common Octal Sets*:
* **`0755` (`rwxr-xr-x`)**: Standard directory or executable script (User full access, Group/Others read and execute).
* **`0644` (`rw-r--r--`)**: Standard document file (User read/write, Group/Others read-only).
* **`0700` (`rwx------`)**: Private user directory or sensitive script.

### Modifying Permissions (`chmod`)
The `chmod` command sets or updates file access permissions.
* **Octal Notation**: `chmod 0750 daily-tasks.sh` (Sets `rwx` for User, `r-x` for Group, `---` for Others).
* **Recursive Option**: `chmod -R 0755 /shared_directory/` applies permissions across a directory tree.
