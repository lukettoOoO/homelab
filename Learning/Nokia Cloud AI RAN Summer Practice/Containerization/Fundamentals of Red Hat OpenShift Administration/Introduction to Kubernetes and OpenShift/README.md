# Chapter 1: Introduction to Kubernetes and OpenShift

## 1. Containers and Kubernetes Fundamentals

### Containers Overview
* **Definition**: An isolated process that packages an application along with all its runtime dependencies, allowing execution across host environments without dependency conflicts.
* **Kernel Isolation Technologies**:
  * **cgroups (Control Groups)**: Manages and limits hardware resource allocation (CPU time, memory, disk I/O, network).
  * **Kernel Namespaces**: Isolates system resources and process spaces between containers and the host (PID, mount, network stack, IPC, UTS, user).
* **Open Container Initiative (OCI)**: Governance body maintaining open industry standards for container image formats and runtime specifications.

### Kubernetes Overview & Architecture
Kubernetes is an open-source orchestration platform that automates deployment, scaling, and operational management of containerized workloads across multi-node clusters.
- The purpose of the deployment of containers is to ensure the availability of the application. It specifies the image, the number of replicas, the resources, etc. But the deployment controller constantly checks the actual state of the cluster and compares it to the desired state. If there is a mismatch, it will try to reconcile the cluster state to match the desired state.
- The deployment makes use of an image stream which can be defined by the user or can be an upstream image. It tracks different versions of the same image and can be used to deploy a specific version of the image.
```
                            ┌─────────────────────────────────────────┐
                            │          Control Plane Nodes            │
                            │ (API Server, etcd, Scheduler, Controllers)│
                            └────────────────────┬────────────────────┘
                                                 │
                   ┌─────────────────────────────┴─────────────────────────────┐
                   ▼                                                           ▼
     ┌───────────────────────────┐                               ┌───────────────────────────┐
     │   Compute / Worker Node   │                               │   Compute / Worker Node   │
     │ (CRI-O, Kubelet, Pods)    │                               │ (CRI-O, Kubelet, Pods)    │
     └───────────────────────────┘                               └───────────────────────────┘
```

* **Control Plane Nodes**: Manage global cluster coordination, API processing, scheduling workloads, and persisting cluster state in `etcd`.
* **Compute (Worker) Nodes**: Execute application container workloads managed by the `kubelet` agent and the container runtime (CRI-O).
* **Pod**: The smallest atomic unit in Kubernetes. Consists of one or more co-located containers executing on the same cluster node, sharing storage volumes and network IPC namespaces.

### Key Kubernetes Features

| Feature | Technical Mechanism |
| :--- | :--- |
| **Service Discovery & Load Balancing** | Provisions internal DNS resolution and load balances incoming network traffic across backend pod replicas using hostnames instead of static IP addresses. |
| **Horizontal Scaling** | Automatically creates or deletes pod replicas based on CPU/RAM metrics or custom application load indicators. |
| **Self-Healing** | Continuously executes health probes (`liveness`/`readiness`) to automatically restart crashed containers or reschedule pods from failed nodes. |
| **Automated Rollout & Rollback** | Performs progressive, zero-downtime rolling updates of container versions with automated rollback capabilities if deployment checks fail. |
| **Secrets & Config Management** | Decouples sensitive credentials (passwords, tokens) and environment configurations from container image builds. *(Note: Kubernetes secrets are base64 encoded, not encrypted by default).* |
| **Declarative Resource Management** | Administrators define target states in text/YAML manifests. Internal controllers continuously poll and reconcile the actual cluster state to match the declared target state. |

---

## 2. Red Hat OpenShift Components and Product Editions

### OpenShift Value Additions over Kubernetes
Vanilla Kubernetes provides building blocks but requires external integrations. Red Hat OpenShift Container Platform (RHOCP) extends Kubernetes into an enterprise-ready application platform by integrating:

* **Integrated Developer Workflows**: Internal container registry, automated CI/CD build pipelines, and Source-to-Image (S2I) build tools.
* **Platform & Application Observability**: Built-in cluster monitoring (Prometheus/Grafana), logging stacks (Vector/Loki/EFK), and event management.
* **Immutable Infrastructure (RHEL CoreOS)**: Runs on Red Hat Enterprise Linux CoreOS (RHCOS), an immutable, container-optimized operating system managed via Kubernetes declarative configurations.
* **Unified Web Console**: Integrated graphical user interface for cluster administrators, developers, and virtualization operators.

### Red Hat OpenShift Product Editions

#### 1. Exploration & Local Development
* **Red Hat OpenShift Local**: Runs a single-node testing cluster on a local workstation.
* **Developer Sandbox**: Provides 30 days of free, shared cloud cluster access for development testing.

#### 2. Self-Managed Offerings (Customer Operates Infrastructure & Updates)
* **Red Hat OpenShift Kubernetes Engine**: Hardened enterprise Kubernetes runtime on RHEL CoreOS with OpenShift Virtualization.
* **Red Hat OpenShift Container Platform (OCP)**: Adds full developer tooling, developer console, log management, cost metering, OpenShift Serverless (Knative), Service Mesh (Istio), Pipelines (Tekton), and GitOps (Argo CD).
* **Red Hat OpenShift Platform Plus**: Full enterprise suite including OCP, Advanced Cluster Management (RHACM), Advanced Cluster Security (RHACS), and Quay private registry.
* **Red Hat OpenShift Virtualization Engine**: Specialized edition tailored specifically for running and scaling Virtual Machine (VM) workloads alongside containers.

#### 3. Managed Cloud Services (Red Hat & Cloud Provider Joint SRE Management)
* **ROSA**: Red Hat OpenShift Service on AWS.
* **ARO**: Microsoft Azure Red Hat OpenShift.
* **ROSD**: Red Hat OpenShift Dedicated.
* *Insights Advisor*: Analyzes telemetry data via the Insights Operator to provide automated remediation recommendations on the Red Hat Hybrid Cloud Console.

---

## 3. Navigating the OpenShift Web Console

### Accessing the Web Console via CLI
Discover the web console URL from the command line after authenticating:
```bash
# Authenticate to cluster API
oc login -u developer -p developer https://api.ocp4.example.com:6443

# Retrieve web console URL
oc whoami --show-console
```

### Web Console Perspectives
The OpenShift Web Console provides role-tailored interface perspectives:
* **Administrator Perspective**: Focuses on infrastructure management, node health, storage provisioning, network routing, operators, and cluster security.
* **Developer Perspective**: Focuses on application topology, Git/S2I code imports, build tracking, and project-level workloads.
* **Virtualization Perspective**: Focuses on deploying, monitoring, and managing virtual machines.

### Essential Concepts & Resource Terms
* **Projects**: OpenShift namespace wrappers providing multi-tenant access control, resource quotas, and network isolation boundaries.
* **Routes**: OpenShift-specific resource that exposes an internal `Service` to external network traffic outside the cluster using built-in HAProxy ingress routers.
* **OperatorHub**: Integrated marketplace used to discover, install, and manage cluster operators.

---

## 4. Monitoring & Cluster Operations

### Machines, Nodes, and Machine Configs
* **Machine Resource**: Abstracted Kubernetes resource describing an underlying node's hardware/cloud spec.
* **Machine Config Operator (MCO)**: Cluster-level operator that manages node OS updates, `kubelet` configs, `crio` settings, SSH keys, and kernel parameters.
* **MachineConfigPool (MCP)**: Groups nodes (e.g., `master` or `worker`) to apply `MachineConfig` changes systematically. MCO updates are prioritized alphabetically by zone using the label `topology.kubernetes.io/zone`.

### Direct Node Diagnostic Access
Administrators can initiate interactive terminal access to cluster nodes directly from the Web Console:
1. Navigate to **Compute → Nodes** and select a node (e.g., `master01`).
2. Open the **Terminal** tab.
3. Run `chroot /host` to access system binaries.
4. Execute systemd inspection commands:
   ```bash
   # Inspect node agent daemon
   systemctl status kubelet

   # Inspect container runtime daemon
   systemctl status crio
   ```

### Observability, Metrics & Events
* **Prometheus Metrics (`Observe → Metrics`)**: Collects data from `/metrics` endpoints via `ServiceMonitor` or `PodMonitor` CRDs. PromQL queries can be executed to build custom performance graphs.
* **Alerting Rules (`Observe → Alerting`)**: Displays active firing alerts and rule definitions based on threshold violations.
* **Cluster Events (`Home → Events`)**: Chronological event stream tracking real-time cluster actions, pod scheduling, and system warnings.
* **API Explorer (`Home → API Explorer`)**: Catalog documenting all available Kubernetes and OpenShift Custom Resource Definitions (CRDs), schemas, and metadata.
