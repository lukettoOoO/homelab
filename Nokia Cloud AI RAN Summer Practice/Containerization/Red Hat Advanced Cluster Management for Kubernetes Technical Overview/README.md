# Red Hat Advanced Cluster Management for Kubernetes — Technical Overview

---

## 1. Red Hat Advanced Cluster Management for Kubernetes Overview

**Red Hat Advanced Cluster Management (RHACM)** is an enterprise-grade multi-cluster management solution built on top of Open Cluster Management (OCM), an open-source community project. It enables teams to manage the full lifecycle of Kubernetes clusters and the applications running on them from a single control plane.

### Key Capabilities

| Capability                     | Description                                                                              |
| ------------------------------ | ---------------------------------------------------------------------------------------- |
| **Cluster Lifecycle**          | Provision, import, upgrade, and destroy clusters across any infrastructure               |
| **Multicluster Observability** | Centralized monitoring, metrics, and alerting across all managed clusters                |
| **Application Lifecycle**      | Deploy and manage applications across clusters using GitOps or subscription-based models |
| **Policy Engine**              | Enforce governance, risk, and compliance (GRC) across clusters                           |
| **Virtual Machine Management** | Manage VMs via OpenShift Virtualization and GitOps                                       |

### Architecture

- **Hub Cluster**: The central management cluster where RHACM is installed. Hosts the control plane components.
- **Managed Clusters**: Any Kubernetes/OpenShift clusters registered to the hub. They run lightweight agents that communicate back to the hub.
- **klusterlet**: The agent deployed on each managed cluster; handles registration, status reporting, and executing work sent from the hub.
- **Multicluster Engine (MCE)**: The foundational layer beneath RHACM that provides cluster lifecycle and import capabilities.

### Supported Cluster Types

- OpenShift Container Platform (OCP)
- Other Kubernetes distributions (EKS, GKE, AKS, etc.) — importable as managed clusters
- Single-node OpenShift (SNO)
- Hypershift-based hosted control planes

---

## 2. Cluster Lifecycle

Cluster Lifecycle covers the **creation, import, upgrade, scaling, and destruction** of Kubernetes clusters from the hub.

### Cluster Provisioning Methods

| Method                                         | Description                                                                                                                                           |
| ---------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Installer Provisioned Infrastructure (IPI)** | RHACM automates full cluster provisioning on supported cloud providers (AWS, Azure, GCP, VMware, Bare Metal)                                          |
| **Assisted Installer**                         | Guided, on-premise bare-metal installation with a web-based wizard                                                                                    |
| **Hypershift (Hosted Control Planes)**         | Runs the Kubernetes control plane as pods on the hub cluster; workers are on managed infrastructure. Greatly reduces footprint for edge/SNO use cases |
| **Import (Bring Your Own Cluster)**            | Manually or automatically import existing clusters by deploying the klusterlet agent                                                                  |

### Key Concepts

- **ClusterPool**: A pool of pre-provisioned clusters that can be claimed on-demand (useful for CI/CD environments).
- **ClusterSet**: A logical grouping of managed clusters used for RBAC and placement decisions.
- **ClusterClaim**: A request to claim a cluster from a ClusterPool.
- **ManagedCluster** CRD: The Kubernetes custom resource on the hub that represents each managed cluster.
- **Placement / PlacementRule**: Defines which managed clusters receive workloads or policies based on labels and cluster attributes.

### Cluster Upgrade

- RHACM can orchestrate **cluster upgrades** using the `ClusterCurator` resource.
- Supports pre/post upgrade hooks (Ansible jobs or custom jobs).
- Works with the OpenShift update service to select target versions.

### Infrastructure Environment (InfraEnv)

- Used with the Assisted Installer to define the environment for bare-metal host discovery.
- Generates ISO images that nodes boot from to be discovered and registered.

---

## 3. Multicluster Observability

Multicluster Observability provides a **centralized, unified view** of metrics, alerts, and logs from all managed clusters without needing to access each cluster individually.

### Architecture

```
Hub Cluster
└── MulticlusterObservability Operator
    ├── Thanos (long-term metrics storage & querying)
    ├── Grafana (dashboards)
    ├── Alertmanager (alert routing)
    └── Object Storage (S3-compatible backend — required)

Managed Clusters
└── Observability Add-on (metrics-collector)
    └── Pushes metrics → Hub Thanos Receive
```

### Components

| Component             | Role                                                                             |
| --------------------- | -------------------------------------------------------------------------------- |
| **Thanos**            | Aggregates and stores metrics from all clusters; enables long-term retention     |
| **Grafana**           | Pre-built dashboards for fleet-wide cluster health (CPU, memory, nodes, pods)    |
| **Alertmanager**      | Routes alerts; integrates with PagerDuty, Slack, email, etc.                     |
| **metrics-collector** | Lightweight agent on each managed cluster; scrapes Prometheus and forwards data  |
| **Object Storage**    | S3-compatible backend (e.g., AWS S3, MinIO, ODF) required for Thanos persistence |

### Custom Metrics & Dashboards

- Default set of metrics is collected; the `allow-list` ConfigMap can be extended to include custom metrics.
- Custom Grafana dashboards can be added via ConfigMaps on the hub.
- **Search** capability: Kubernetes resources across all clusters are indexed and searchable from the RHACM console.

### Multicluster Observability Add-on

- Deployed automatically to managed clusters when observability is enabled.
- Can be disabled per-cluster via an annotation on the `ManagedCluster` resource.

---

## 4. Application Lifecycle

RHACM provides two main models for deploying applications across managed clusters:

### Model 1: RHACM Subscription-based (Pull Model)

Uses custom resources to define **what** to deploy and **where** to deploy it.

#### Key Resources

| Resource                      | Description                                                                       |
| ----------------------------- | --------------------------------------------------------------------------------- |
| **Channel**                   | Points to a source of application manifests: Git repo, Helm repo, or ObjectBucket |
| **Subscription**              | Links a Channel to a set of clusters; defines what to deploy from that channel    |
| **PlacementRule / Placement** | Selects target clusters based on labels, conditions, or capacity                  |
| **Application**               | Logical grouping resource that ties Subscriptions together for the console view   |

#### Flow

```
Channel (Git/Helm/S3)
    └── Subscription (what to deploy + Placement)
            └── PlacementRule → selects Managed Clusters
                    └── Application manifests deployed on target clusters
```

### Model 2: GitOps (ArgoCD / OpenShift GitOps Integration)

RHACM integrates natively with **OpenShift GitOps (ArgoCD)** for a push/pull GitOps workflow across clusters.

- **GitOpsCluster** resource: Registers managed clusters as ArgoCD destinations, enabling ArgoCD to deploy to them.
- **ApplicationSet**: An ArgoCD resource that can dynamically generate ArgoCD Applications for each cluster in a placement.
- RHACM's Placement resources drive which clusters appear as ArgoCD targets.

#### Workflow

```
RHACM Placement → selects clusters
    └── GitOpsCluster → registers clusters with ArgoCD
            └── ArgoCD ApplicationSet → deploys app to each cluster
```

### Topology View

- RHACM console provides an **application topology view** showing the deployed resources (Deployments, Services, Routes, Pods) across clusters in a visual graph.

---

## 5. Policy Engine

The **Policy Engine** is RHACM's governance, risk, and compliance (GRC) framework. It enables administrators to define desired configuration states and enforce them across all managed clusters.

### Core Concepts

- **Policy**: A hub-side resource that defines the desired state (compliance check or enforcement) for managed clusters.
- **PlacementBinding**: Binds a Policy to a PlacementRule/Placement, determining which clusters the policy applies to.
- **PolicySet**: Groups multiple policies together; a single PlacementBinding can target a PolicySet.

### Policy Structure

```yaml
apiVersion: policy.open-cluster-management.io/v1
kind: Policy
metadata:
  name: policy-namespace
  namespace: policies
spec:
  remediationAction: enforce  # or: inform
  disabled: false
  policy-templates:
    - objectDefinition:
        apiVersion: policy.open-cluster-management.io/v1
        kind: ConfigurationPolicy
        ...
```

### Policy Templates (Built-in)

| Template Type           | Purpose                                                                       |
| ----------------------- | ----------------------------------------------------------------------------- |
| **ConfigurationPolicy** | Enforce or audit Kubernetes resource configurations (must-have/must-not-have) |
| **CertificatePolicy**   | Alert on expiring certificates                                                |
| **IamPolicy**           | Limit cluster-admin bindings                                                  |
| **OperatorPolicy**      | Manage operator installation via OLM                                          |

### Remediation Actions

- **`inform`**: RHACM reports non-compliance but does not make changes. Used for auditing.
- **`enforce`**: RHACM automatically remediates non-compliant resources to match the desired state.

### Policy Hub Templates

- Policies support **hub-side templating** using `{{hub ... hub}}` syntax to inject dynamic values (e.g., secrets, cluster-specific data) at deployment time without hardcoding.

### Compliance Dashboard

- The RHACM console provides a **GRC dashboard** showing:
  - Which clusters are compliant/non-compliant per policy.
  - Policy violation history.
  - Drill-down into specific policy failures.

### Integration with Policy Generator

- **PolicyGenerator** (Kustomize plugin): Generates RHACM Policy manifests from plain Kubernetes manifests stored in Git. Enables a full GitOps approach to governance.

---

## 6. Managing Virtual Machines with GitOps

RHACM enables management of **Virtual Machines (VMs)** running on OpenShift Virtualization (KubeVirt) across multiple clusters using GitOps patterns.

### OpenShift Virtualization Integration

- **OpenShift Virtualization** (based on KubeVirt) runs VMs as Kubernetes pods.
- VMs are defined as `VirtualMachine` custom resources — making them treatable like any other Kubernetes workload.
- RHACM can **discover, observe, and govern** VMs across clusters alongside containerized workloads.

### GitOps for VM Management

Since VMs are defined as CRDs, the same GitOps patterns used for container workloads apply:

1. **Store VM definitions in Git** (`VirtualMachine`, `DataVolume`, `NetworkAttachmentDefinition` manifests).
2. **Use RHACM Subscriptions or ArgoCD** to deploy VM manifests to target clusters.
3. **Use RHACM Policies** to enforce VM configuration standards (e.g., resource limits, network policies).

#### Example GitOps Flow for VMs

```
Git Repository
└── vm-definitions/
    ├── virtualmachine.yaml
    ├── datavolume.yaml
    └── service.yaml
        └── RHACM Subscription / ArgoCD App
                └── Deploys to target OpenShift Virtualization clusters
```

### VM Placement

- Use **PlacementRule/Placement** with cluster labels to target clusters running OpenShift Virtualization.
- Label managed clusters (e.g., `capability: openshift-virtualization`) to distinguish VM-capable clusters.

### Observability for VMs

- VM metrics (CPU, memory, network, disk I/O) from KubeVirt are collected by the observability add-on.
- Pre-built and custom Grafana dashboards can visualize VM performance across clusters.

### Policy Enforcement for VMs

- RHACM ConfigurationPolicies can ensure:
  - OpenShift Virtualization operator is installed and healthy.
  - VMs meet resource request/limit standards.
  - Specific VM configurations are consistent across clusters.

---

## Summary

```
RHACM Hub
├── Cluster Lifecycle      → Provision, import, upgrade, destroy clusters
├── Observability          → Centralized metrics, dashboards, alerts (Thanos + Grafana)
├── Application Lifecycle  → Deploy apps via Subscriptions (Git/Helm) or ArgoCD/GitOps
├── Policy Engine          → Governance, compliance enforcement (GRC)
└── VM Management          → GitOps-driven VM lifecycle on OpenShift Virtualization
```

> **Key insight**: RHACM treats everything — containers, operators, VMs, and policies — as Kubernetes resources, enabling a single unified GitOps workflow for the entire fleet.
