# Chapter 3: Run Applications as Containers and Pods

## 1. Creating Linux Containers and Kubernetes Pods

### Imperative Pod Creation (`oc run`)
While enterprise production applications are deployed using declarative YAML manifests (e.g., `Deployment` resources), the `oc run` command provides an imperative method for launching unmanaged pods for temporary tasks, testing, or interactive troubleshooting.

```bash
# Basic pod creation
oc run web-server --image registry.access.redhat.com/ubi9/httpd-24
```

#### Key `oc run` Flags and Execution Options

| Flag / Option | Description & Syntax | Practical Usage |
| :--- | :--- | :--- |
| `--command -- <cmd> <args>` | Overrides the default `ENTRYPOINT`/`CMD` defined in the container image. | `oc run test-pod --image ubi9 --command -- /bin/bash -c "whoami && id"` |
| `-- <args>` | Passes custom arguments to the image's default `ENTRYPOINT`. | `oc run date-pod --image ubi9 -- date` |
| `-it` | Opens an interactive session (`-i` keeps `stdin` open; `-t` allocates a pseudo-TTY). | `oc run -it debug-shell --image ubi9 --command -- /bin/bash` |
| `--restart=<policy>` | Sets the pod restart policy: `Always` (default), `OnFailure`, or `Never`. | `oc run job-pod --image ubi9 --restart Never --command -- date` |
| `--rm` | Automatically deletes the pod upon container exit. | `oc run -it temp-check --rm --image ubi9 --restart Never -- date` |
| `--env="KEY=VAL"` | Sets container environment variables. | `oc run db --image mysql-80 --env MYSQL_ROOT_PASSWORD=redhat123` |

---

### User ID (UID) and Group ID (GID) Assignment in OpenShift

OpenShift enforces strict multi-tenant security by automatically controlling the User IDs (UIDs) and Group IDs (GIDs) assigned to container processes.

```
                   ┌─────────────────────────────────────────────────┐
                   │            OpenShift Project Annotations        │
                   ├─────────────────────────────────────────────────┤
                   │ openshift.io/sa.scc.uid-range: 1000760000/10000 │
                   │ openshift.io/sa.scc.supplemental-groups: ...    │
                   └────────────────────────┬────────────────────────┘
                                            │
           ┌────────────────────────────────┴────────────────────────────────┐
           ▼                                                                 ▼
┌──────────────────────────────────────┐                   ┌──────────────────────────────────────┐
│       Regular User Pod Creation      │                   │     Cluster Admin Pod Creation       │
├──────────────────────────────────────┤                   ├──────────────────────────────────────┤
│ • Image USER instruction IGNORED.    │                   │ • Image USER instruction HONORED.    │
│ • Random UID assigned from allocated │                   │ • Container can run as root (UID 0)  │
│   project range (e.g., 1000760000).  │                   │   or specified image user.           │
│ • Primary GID is ALWAYS 0 (root).    │                   │ • Potential host security risk!      │
└──────────────────────────────────────┘                   └──────────────────────────────────────┘
```

#### Project UID and GID Range Allocations
When a project is created, OpenShift assigns a dedicated block of UIDs and supplemental GIDs stored in project annotations (inspectable via `oc describe project <name>`):
* **Format**: `base/size` (e.g., `1000760000/10000` defines a block of 10,000 UIDs starting from `1000760000`).

#### Regular Users vs. Cluster Administrators

1. **Regular Cluster Users (Default Non-Root Security)**:
   * OpenShift **ignores** the `USER` instruction in the container image.
   * OpenShift assigns a random, high-numbered non-root UID from the project's allocated `uid-range`.
   * The primary Group ID (GID) is always **`0` (root group)**.
   * **Group 0 (root group) Requirement**: Because non-root UIDs are dynamically assigned, any containerized application writing to internal directories or files must ensure that those target locations are **owned by GID 0 (`root`)** and have **group-write permissions (`g+rw`)**.

2. **Cluster Administrators**:
   * OpenShift **honors** the `USER` instruction in the container image.
   * Admin-created pods can run as UID `0` (`root`), gaining unrestricted root privileges inside the container. *Note: Running containers as root poses severe host security risks.*

---

### Pod Security & Admission Controllers
* **Pod Security Admission (PSA)**: Enforces cluster-wide baseline, restricted, or privileged security profiles at the namespace level.
* **Security Context Constraints (SCC)**: OpenShift controller granting pods explicit OS-level privileges (e.g., host networking, volume mounts, capabilities) based on RBAC authorization.

---

### Interacting with Running Pods

```bash
# Execute a command in a running pod
oc exec my-pod -- date

# Execute a command in a specific container of a multi-container pod
oc exec my-pod -c app-container -- date

# Open an interactive shell inside a container
oc exec -it my-pod -c app-container -- /bin/bash

# View container logs
oc logs my-pod -c app-container --tail=20 -f

# Attach directly to a running container process
oc attach my-pod -it -c app-container
```

#### Deleting Resources (`oc delete`)
```bash
# Delete by resource type and name
oc delete pod web-server

# Delete by label selector
oc delete pod -l app=my-app

# Graceful termination control
oc delete pod web-server --grace-period=10

# Immediate termination (grace-period 1s)
oc delete pod web-server --now

# Force deletion (bypasses node confirmation)
oc delete pod web-server --force
```

---

### CRI-O Container Engine and Node Debugging (`crictl` & `nsenter`)

OpenShift control plane and worker nodes run **CRI-O**, a lightweight container runtime built specifically for Kubernetes Container Runtime Interface (CRI) compliance.

```
[Workstation] ---> oc debug node/master01 ---> [Debug Pod Shell] ---> chroot /host ---> [Host Binaries: crictl, lsns, nsenter]
```

#### Node-Level Troubleshooting Workflow (Cluster Admin Only)

1. **Start a Node Debug Session**:
   ```bash
   oc debug node/master01
   ```
2. **Access Host File System & Executable Binaries**:
   ```bash
   chroot /host
   ```
3. **Manage Containers with `crictl`**:
   ```bash
   # List pods and running containers on the node
   crictl pods
   crictl ps --name my-app

   # Extract full container ID and process PID using jq or Go templates
   CID=$(crictl ps --name my-app -o json | jq -r .containers[0].id)
   PID=$(crictl inspect --output go-template --template '{{.info.pid}}' $CID)
   echo "Container PID: $PID"
   ```
4. **Inspect Linux Kernel Namespaces (`lsns`)**:
   ```bash
   # List all isolated Linux namespaces (uts, ipc, net, mnt, pid, user, cgroup) for the PID
   lsns -p $PID
   ```
5. **Enter Container Namespaces (`nsenter`)**:
   ```bash
   # Execute a host command inside the container's PID namespace
   nsenter -t $PID -p -r ps -ef

   # Execute a command inside ALL container namespaces
   nsenter -t $PID -a ps -ef
   ```

---

## 2. Finding and Inspecting Container Images

### Image Registries
Container images are distributed through public and private image registries:
* **Red Hat Ecosystem Catalog** (`catalog.redhat.com`): Verified enterprise container images with security risk scores and package details.
* **Red Hat Registry** (`registry.redhat.io`): Authenticated registry storing enterprise RHEL and OpenShift product images.
* **Quay.io** (`quay.io`): High-performance container registry featuring automated vulnerability scanning and fine-grained access control.
* **Classroom / Private Registries** (`registry.access.redhat.com` / local registries): Host public Universal Base Images (UBI) and internal project builds.

---

### Red Hat Universal Base Images (UBI)

Red Hat UBI container images provide enterprise-grade RHEL-based operating system layers that are **freely redistributable** without requiring a Red Hat subscription.

| UBI Variant | Included Components & Features | Target Use Cases |
| :--- | :--- | :--- |
| **Standard** | Full base image including DNF package manager, systemd, and utilities (`tar`, `gzip`). | General application development and complex workloads. |
| **Init** | Includes systemd init system configured to run multiple services inside a single container. | Multi-service legacy containerization. |
| **Minimal** | Compact image replacing full DNF with lightweight `microdnf`. | Reduced footprint microservices requiring occasional package installs. |
| **Micro** | Smallest UBI footprint; excludes package managers completely. | Minimal attack surface, ultra-lightweight binaries. |

---

### Container Image Identifiers & Components

#### Image Naming Convention
A fully qualified container image reference consists of four distinct parts:
`registry.access.redhat.com / ubi9 / httpd-24 : 1-233`
* `registry.access.redhat.com`: **Registry Hostname**
* `ubi9/httpd-24`: **Repository Name**
* `1-233`: **Tag** (*Fixed tag* points to a specific build; *Floating tag* like `latest` or `1` points dynamically to the newest build).
* **Digest / SHA Hash**: Immutable SHA256 identifier referencing exact byte content (e.g., `sha256:4186a1e...`).

#### Core Containerfile Instructions & Metadata

| Instruction | Type | Functional Effect on Runtime Container |
| :--- | :--- | :--- |
| `ENV` | State | Sets environment variables accessible to container processes. |
| `ARG` | Build-time | Sets build-time variables passed during image compilation. |
| `USER` | State | Defines the default execution UID/GID (ignored for non-admin users in OpenShift). |
| `ENTRYPOINT` | State | Sets the primary executable command run when the container starts. |
| `CMD` | State | Sets default arguments passed to `ENTRYPOINT` (or default shell command if `ENTRYPOINT` is unset). |
| `WORKDIR` | State | Sets the working directory path for subsequent instructions and commands. |
| `EXPOSE` | Metadata | Informational metadata specifying container network listening ports (does not bind host ports). |
| `VOLUME` | Metadata | Informational metadata specifying persistent mount paths. |

---

### Remote Image Inspection & Management Tools

#### 1. Skopeo (`skopeo`)
`skopeo` inspects and copies remote container images **without requiring a running container engine, root privileges, or a local daemon**.

```bash
# Login to a container registry
skopeo login registry.ocp4.example.com:8443

# List all available tags for a remote repository
skopeo list-tags docker://registry.ocp4.example.com:8443/rhel9/mysql-80

# Inspect remote image configuration and environment metadata
skopeo inspect --config docker://registry.ocp4.example.com:8443/rhel9/mysql-80:latest

# Format inspection output using Go templates
skopeo inspect --format "Digest: {{.Digest}} Release: {{.Labels.release}}" docker://...

# Copy an image between registries
skopeo copy docker://quay.io/skopeo/stable:latest docker://registry.example.com/skopeo:latest
```
*Credential Storage*: Skopeo stores base64-encoded registry credentials in `${XDG_RUNTIME_DIR}/containers/auth.json`.

#### 2. OpenShift Image Utilities (`oc image`)
```bash
# Inspect image metadata and layers
oc image info registry.access.redhat.com/ubi9/httpd-24:latest --filter-by-os amd64

# Mirror container images between registries or to local disk
oc image mirror registry.access.redhat.com/ubi9/httpd-24 registry.example.com/httpd-24

# Extract files from an image directly to local disk without running a container
oc image extract registry.access.redhat.com/ubi9/httpd-24 --path=/etc/httpd/conf:./conf
```

---

## 3. Troubleshooting Containers and Pods

Containers are designed to be **immutable and ephemeral**. Modifying a running container is strictly an emergency troubleshooting step to diagnose errors before updating source code and redeploying.

### Essential CLI Troubleshooting Toolset

```
┌───────────────────────────────────────────────────────────────────────────┐
│                      OpenShift CLI Troubleshooting Suite                  │
├───────────────────────────────────────────────────────────────────────────┤
│ • oc describe  : Inspect detailed metadata, status conditions, & events   │
│ • oc logs      : Retrieve container stdout/stderr output (-f, --tail, -p) │
│ • oc edit      : Interactively update live resource definitions in YAML    │
│ • oc patch     : Programmatically update specific manifest JSON paths     │
│ • oc cp        : Copy files/directories into or out of running containers │
│ • oc rsync     : Synchronize directory trees between host and container   │
│ • oc port-forward : Tunnel local workstation ports directly to pod ports   │
│ • oc rsh       : Open a remote interactive shell in a container          │
│ • oc debug     : Create an exact debug copy of a failing pod or node      │
└───────────────────────────────────────────────────────────────────────────┘
```

---

### Step-by-Step Troubleshooting Workflows

#### Workflow 1: Diagnosing `ImagePullBackOff` & Image Tag Errors
1. Inspect pod status and failure events:
   ```bash
   oc get pods
   oc get events
   ```
2. Inspect remote registry tags using Skopeo:
   ```bash
   skopeo list-tags docker://registry.ocp4.example.com:8443/rhel9/mysql-80
   ```
3. Update pod configuration live to point to a valid tag:
   ```bash
   oc edit pod/mysql-server
   # Modify image string under spec.containers[0].image
   ```

#### Workflow 2: Diagnosing Container Startup Failures (`CrashLoopBackOff`)
1. View logs of the current or previously failed container instance:
   ```bash
   oc logs mysql-server --tail=50
   oc logs mysql-server -p  # View logs of previous crashed container
   ```
2. Verify missing mandatory environment variables (e.g., `MYSQL_ROOT_PASSWORD`):
   ```bash
   oc run mysql-server --image mysql-80      --env MYSQL_USER=redhat      --env MYSQL_PASSWORD=redhat123      --env MYSQL_DATABASE=world
   ```

#### Workflow 3: Copying Files & Database Initialization
```bash
# Copy local SQL script into running container (requires tar binary in container)
oc cp ./world_x.sql mysql-server:/tmp/world_x.sql

# Open shell and execute database import
oc rsh mysql-server
sh-5.1$ mysql -u redhat -pworld123 world < /tmp/world_x.sql
```

#### Workflow 4: Debugging Applications via Port-Forwarding
To test application connectivity directly from a local workstation without exposing a public Route or Service:
```bash
# Forward local port 3306 to container port 3306
oc port-forward mysql-server 3306:3306
```
In a secondary local terminal window, connect via local client tools:
```bash
mysql -u redhat -p -h 127.0.0.1 -P 3306
```
