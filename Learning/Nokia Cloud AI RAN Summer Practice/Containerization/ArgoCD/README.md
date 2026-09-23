# Argo CD & OpenShift GitOps

## 1. Fundamentals of GitOps & Argo CD

### What is GitOps?

GitOps is an operational framework that takes DevOps best practices used for application development—such as version control, collaboration, compliance, and CI/CD—and applies them to infrastructure automation and application deployment.

- **Declarative Descriptions**: The entire system state (infrastructure, configurations, and applications) is described declaratively in Git.
- **Git as the Single Source of Truth**: Git repositories are the authoritative source for the desired state. Any approved change must first be committed to Git.
- **Automated Reconciliation**: Software agents monitor both the desired state in Git and the actual runtime state in the cluster, reconciling any discrepancies.
- **Software Agents for Self-Healing**: If changes occur directly on the cluster (configuration drift), the system automatically reverts or alerts on drift.

---

### What is Argo CD?

[Argo CD](https://argo-cd.readthedocs.io/) is a declarative, continuous delivery tool for Kubernetes following the GitOps pattern. It automates the deployment of desired application states into target Kubernetes/OpenShift clusters.

#### Core Architecture & Components

- **`argocd-server`**: API server exposing the Web UI, CLI access (gRPC/REST), and authentication endpoints.
- **`argocd-repo-server`**: An internal service maintaining a local cache of Git repositories and generating Kubernetes manifests from templates (Plain YAML, Kustomize, Helm, Jsonnet).
- **`argocd-application-controller`**: The continuous reconciliation engine. It polls the cluster API and Git repository, computes differences (`OutOfSync` vs `Synced`), and performs sync/reconciliation workflows.
- **`argocd-dex-server`**: An embedded identity service providing OIDC/OAuth integration (e.g., OpenShift OAuth, GitHub, GitLab, LDAP).
- **`argocd-redis`**: Caching layer for repository state, cluster resources, and tokens.
- **`argocd-applicationset-controller`**: Manages `ApplicationSet` custom resources, allowing multi-cluster, multi-tenant application generators.

---

## 2. Argo CD Custom Resource Definitions (CRDs)

### The `Application` CRD

The primary abstraction representing a deployed application instance.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bgd-app
  namespace: argocd
spec:
  # Target destination cluster and namespace
  destination:
    namespace: bgd
    server: https://kubernetes.default.svc
  # Project boundary
  project: default
  # Source Git repository and path
  source:
    repoURL: https://github.com/redhat-developer-demos/openshift-gitops-examples
    targetRevision: minikube
    path: apps/bgd/overlays/bgd
  # Automated sync and healing behavior
  syncPolicy:
    automated:
      prune: true # Remove resources deleted from Git
      selfHeal: true # Revert manual changes applied directly to cluster
    syncOptions:
      - CreateNamespace=true
```

### The `AppProject` CRD

Provides logical boundaries to restrict what Applications within the project can do:

- Whitelist/blacklist target clusters and namespaces.
- Whitelist/blacklist resource types (e.g., restrict cluster-scoped resources like `ClusterRoleBinding`).
- Define project-level RBAC and JWT tokens for CI pipelines.

---

## 3. Hands-On Setup & Environment Engineering

### Minikube Setup with Docker Driver

When running on local Linux or VM environments (such as Rocky Linux inside a hypervisor):

```bash
# Start Minikube using Docker container driver (avoiding nested virtualization)
minikube start -p gitops --driver=docker --cpus=3 --memory=4096

# Enable Ingress controller
minikube addons enable ingress -p gitops
```

### Server-Side Apply vs. Client-Side Apply (`metadata.annotations` Size Limit)

When applying large CRDs (like `applicationsets.argoproj.io`):

- Standard `kubectl apply -f` uses client-side apply, which attempts to store the whole manifest inside the `kubectl.kubernetes.io/last-applied-configuration` annotation.
- This fails with: `The CustomResourceDefinition ... is invalid: metadata.annotations: Too long: may not be more than 262144 bytes`.
- **Fix**: Use Server-Side Apply:
  ```bash
  kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  ```

### Cross-Architecture Container Emulation (ARM64 / Apple Silicon)

Running legacy `amd64` (Intel/x86_64) images on ARM64 (`aarch64`) nodes triggers:
`exec /usr/bin/container-entrypoint: exec format error (Exit Code 255)`.

- **Root Cause**: The container's ELF binary is compiled for x86_64 instructions, unsupported by the ARM64 CPU.
- **Resolution via QEMU binfmt**:
  ```bash
  # Enable kernel-level binfmt_misc translation for all containers
  sudo docker run --privileged --rm tonistiigi/binfmt --install all
  ```

### Ingress Routing & Host Forwarding

- In Minikube with the Docker driver, the Ingress controller listens on the Minikube internal IP (e.g., `192.168.49.2:80`).
- To expose hostnames (`bgd.devnation`, `bgdk.devnation`) to an external host (e.g. host Mac):
  1. Add DNS mappings to `/etc/hosts`:
     ```text
     127.0.0.1 bgd.devnation bgdk.devnation
     ```
  2. Create an SSH tunnel forwarding port 80 to the Minikube IP:
     ```bash
     sudo ssh -L 80:192.168.49.2:80 <user>@<VM_IP>
     ```

---

## 4. Configuration Drift & Self-Healing

### Configuration Drift

Configuration drift occurs when runtime resources diverge from their version-controlled definition due to manual commands (`kubectl edit`, `kubectl patch`, CLI interventions).

1. **Drift Detection**: Argo CD continually compares cluster live state against the Git repository.
   - Modifying live state:
     ```bash
     kubectl -n bgd patch deploy/bgd --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/env/0/value", "value":"green"}]'
     ```
   - Argo CD UI immediately flags the application as **`OutOfSync`**.

2. **Self-Healing**:
   When `selfHeal: true` is configured in `syncPolicy`:
   - Argo CD rejects the manual override and triggers an automated sync.
   - It reapplies the declarative manifest from Git, returning the application to the desired state.

```yaml
syncPolicy:
  automated:
    prune: true
    selfHeal: true
```

---

## 5. Declarative Customization with Kustomize

[Kustomize](https://kustomize.io/) allows modifying Kubernetes manifests without forking or using runtime template engines. Argo CD features built-in native support for Kustomize.

### Base and Overlay Pattern

```text
apps/bgd/
├── base/                     # Core reusable configuration
│   ├── bgd-deployment.yaml   # Blue color, generic ingress
│   ├── bgd-svc.yaml
│   └── kustomization.yaml
└── overlays/
    ├── bgd/                  # Standard deployment
    └── bgdk/                 # Customization overlay
        ├── bgdk-ns.yaml
        └── kustomization.yaml
```

### Kustomization Manifest (`kustomization.yaml`)

Using `patchesJson6902` to override specific attributes without modifying the base YAML:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: bgdk
resources:
  - ../../base
  - bgdk-ns.yaml
patchesJson6902:
  # Patch Deployment environment variable to yellow
  - target:
      group: apps
      version: v1
      kind: Deployment
      name: bgd
      namespace: bgdk
    patch: |-
      - op: replace
        path: /spec/template/spec/containers/0/env/0/value
        value: yellow
  # Patch Ingress host rule
  - target:
      group: networking.k8s.io
      version: v1
      kind: Ingress
      name: bgd
      namespace: bgdk
    patch: |-
      - op: replace
        path: /spec/rules/0/host
        value: bgdk.devnation
```

---

## 6. Sync Waves & Resource Hooks

Managing complex, multi-tiered deployments (e.g. databases, migrations, web tiers) requires strict sequencing.

### Sync Waves (`argocd.argoproj.io/sync-wave`)

Sync waves order how manifests are applied to the cluster.

- Waves execute in order from **lowest to highest** (negative numbers run first, e.g., `-1`, `0`, `1`, `2`).
- Argo CD **waits for all resources in the current wave to report `Healthy`** before initiating the next wave.

#### Wave Execution Timeline Example (TODO App with PostgreSQL):

| Wave          | Resource                                          | Purpose                                                    |
| :------------ | :------------------------------------------------ | :--------------------------------------------------------- |
| **Wave `-1`** | `Namespace: todo`                                 | Ensures the namespace exists first.                        |
| **Wave `0`**  | `Deployment: postgresql`, `Service: postgres`     | Database engine starts and reaches ready state.            |
| **Wave `1`**  | `Job: todo-table`                                 | Runs SQL migration scripts against the ready database.     |
| **Wave `2`**  | `Deployment: todo-gitops`, `Service: todo-gitops` | Application tier starts once schema exists.                |
| **Wave `3`**  | `Ingress: todo`                                   | External routing is exposed only after backend is healthy. |

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: todo-table
  namespace: todo
  annotations:
    argocd.argoproj.io/sync-wave: '1'
spec:
  # ...
```

---

### Resource Hooks (`argocd.argoproj.io/hook`)

Hooks partition the delivery of manifests into discrete lifecycle phases relative to the main sync.

#### Hook Phases:

- **`PreSync`**: Runs before applying primary manifests (e.g., database schema backups, schema validation).
- **`Sync`**: Normal application manifests run in this phase.
- **`PostSync`**: Runs after the `Sync` phase succeeds (e.g., integration tests, cache warm-ups, notifications, post-install data seeding).
- **`SyncFail`**: Executes if any phase encounters an unrecoverable failure (e.g., rollback triggers, alerts to Slack/PagerDuty).

#### Hook Deletion Policies (`argocd.argoproj.io/hook-delete-policy`):

- `HookSucceeded`: Resource is deleted once it finishes successfully.
- `HookFailed`: Resource is deleted if execution fails.
- `BeforeHookCreation`: Existing hook resource is deleted immediately before a new sync attempts to create it.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: todo-insert
  annotations:
    argocd.argoproj.io/hook: PostSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      containers:
        - name: httpie
          image: alpine/httpie:2.4.0
          command: ['http']
          args: ['POST', 'todo-gitops:8080/api', 'title=Finish ArgoCD tutorial']
```

---

## 7. Red Hat OpenShift GitOps Operator Specifics

In OpenShift, Argo CD is packaged and managed via the **Red Hat OpenShift GitOps Operator** through OperatorHub.

### Default Cluster Instance

- The operator deploys a default Argo CD instance in the `openshift-gitops` namespace.
- Integrates out-of-the-box with OpenShift OAuth (`Login via OpenShift`).

### Required OpenShift Permissions & RBAC

1. **Grant Controller Cluster-Admin Access**:
   Argo CD uses the `openshift-gitops-argocd-application-controller` ServiceAccount to deploy resources:

   ```bash
   oc adm policy add-cluster-role-to-user --rolebinding-name="openshift-gitops-cluster-admin" cluster-admin -z openshift-gitops-argocd-application-controller -n openshift-gitops
   ```

2. **Argo CD User RBAC Group Assignment**:
   To manage applications, the user must belong to the `cluster-admins` group:

   ```bash
   # Check existing groups
   oc get groups

   # Create group and add user
   oc adm groups new cluster-admins <user>
   # Or add to existing group
   oc adm groups add-users cluster-admins <user>
   ```

3. **Retrieve Default Cluster Secret**:
   ```bash
   oc get secret/openshift-gitops-cluster -n openshift-gitops -o jsonpath='{.data.admin\.password}' | base64 -d; echo
   ```
