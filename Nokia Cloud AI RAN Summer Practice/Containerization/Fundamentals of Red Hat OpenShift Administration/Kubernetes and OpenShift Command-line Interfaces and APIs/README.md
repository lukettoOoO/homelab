# Chapter 2: Kubernetes and OpenShift Command-line Interfaces and APIs

## 1. The Kubernetes and OpenShift Command-line Interfaces

### `kubectl` vs. `oc` CLI Overview
An OpenShift cluster can be managed using either the native Kubernetes `kubectl` CLI or the OpenShift `oc` CLI.

```
                      ┌────────────────────────────────────────┐
                      │                 oc CLI                 │
                      │   (Superset of kubectl functionality)  │
                      ├────────────────────────────────────────┤
                      │  • Native OpenShift commands           │
                      │    (oc login, oc new-app, oc status)   │
                      │  • OpenShift CRD Management            │
                      │    (projects, routes, buildconfigs)    │
                      │                                        │
                      │   ┌────────────────────────────────┐   │
                      │   │          kubectl CLI           │   │
                      │   │  (Kubernetes Native Commands)  │   │
                      │   └────────────────────────────────┘   │
                      └────────────────────────────────────────┘
```

* **`kubectl`**: The standard Kubernetes command-line tool. Provides a thin wrapper over the raw Kubernetes REST API.
  * *Version Compatibility*: The `kubectl` client version must be within **one minor version** of the cluster control plane (e.g., a `v1.30` client communicates with `v1.29`, `v1.30`, and `v1.31` control planes).
* **`oc`**: A **superset** of `kubectl`. Includes all standard `kubectl` features plus OpenShift-specific commands (`oc login`, `oc new-project`, `oc new-app`, `oc status`, `oc project`, `oc adm`).
  * The `oc` CLI package embeds `kubectl` natively.

### Installing and Verifying CLI Tools

#### 1. Manual `kubectl` Binary Installation (Linux)
```bash
# 1. Download stable binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# 2. Download and verify SHA256 checksum
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# 3. Install binary to system path
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# 4. Verify client version
kubectl version --client
```

#### 2. Installing `oc` from OpenShift Web Console
Download the exact `oc` binary tailored to your cluster version directly from the OpenShift Web Console under **Help (?) → Command Line Tools**. Available binaries support `x86_64`, `ARM64`, `s390x`, and `ppc64le` architectures across Linux, macOS, and Windows.

### CLI Inspection & Documentation Tools
* **`--help` Flag**: Displays usage syntax, available subcommands, flags, and practical examples for any command (e.g., `kubectl create --help` or `oc create --help`).
* **`oc explain <resource>`**: Queries the server's OpenAPI schema to display field descriptions, data types, and JSONPath structures for any Kubernetes resource.
  * *Field Inspection*: `oc explain pods.spec.containers.resources`
  * *Recursive Schema View*: `oc explain pods --recursive` (lists all nested fields without descriptions).

---

## 2. OpenShift Authentication Methods

Before performing API operations, clients must authenticate. OpenShift verifies identity (Authentication) before evaluating RBAC policies (Authorization).

### User Entity Types in OpenShift
1. **Regular Users**: Standard interactive user accounts represented by `User` resource objects (developers, cluster admins).
2. **System Users**: Infrastructure accounts used by system components to interact securely with the API (`system:admin`, `system:anonymous`).
3. **Service Accounts**: Represented by `ServiceAccount` objects. Enables application pods to authenticate against the API without embedding human credentials.

### Authentication Methods (`oc login`)

| Authentication Method | CLI Syntax | Characteristics & Best Practices |
| :--- | :--- | :--- |
| **Username & Password** | `oc login -u <username> -p <password> <api_url>` | Simple for lab setups. **Not recommended for production** due to plaintext credential risks in shell history. |
| **Token-Based (OAuth)** | `oc login --token=<oauth_token> --server=<api_url>` | **Production Standard**. Uses OAuth tokens issued by OpenShift's built-in OAuth server (`https://oauth-openshift.apps.<cluster>/oauth/token/request`). Ideal for CI/CD pipelines and scripts. |
| **Web Authentication** | `oc login --web <api_url>` | Opens an interactive browser window to authenticate via the configured Identity Provider (IdP) and returns an authorization token to the CLI terminal. |

---

## 3. Managing Cluster Resources at the Command Line

### Project Creation
Projects provide multi-tenant isolation boundaries around Kubernetes namespaces:
```bash
oc new-project myapp
```

### Essential Cluster Administration Commands

#### 1. Cluster Information & APIs
* `oc cluster-info`: Displays control plane endpoints and core service URLs (`oc cluster-info dump` extracts detailed diagnostic state).
* `oc api-versions`: Lists all supported API group versions on the server (e.g., `apps/v1`, `admissionregistration.k8s.io/v1`).
* `oc api-resources`: Lists all supported API resource types, shortnames, API groups, namespaced status, and kinds.
  ```bash
  # Filter namespaced resources in apps group sorted by name
  oc api-resources --namespaced=true --api-group apps --sort-by name
  ```
* `oc get clusteroperator`: Displays the operational state of all core OpenShift cluster operators (`AVAILABLE`, `PROGRESSING`, `DEGRADED`).

#### 2. Resource Querying & Export
* `oc get <resource_type>`: Displays a summary list of resources in the active project.
  * `-o wide`: Shows additional details (IP addresses, node assignments).
  * `-o yaml` / `-o json`: Exports the complete object manifest.
* `oc get all`: Retrieves a high-level summary of all primary resources in the project (pods, services, deployments, replicasets, imagestreams).
* `oc describe <resource_type> <resource_name>`: Displays comprehensive diagnostic metadata, status conditions, and chronological lifecycle events.

#### 3. Imperative & Declarative Resource Management
* `oc create -f <file.yaml>`: Instantiates resources defined in a YAML or JSON manifest file.
* `oc delete <resource_type> <resource_name>`: Removes specified resources from the cluster.
* `oc status`: Provides a high-level overview of application components, routes, builds, and configuration warnings in the active project (`--suggest` recommends fixes).
* `-n <namespace>` / `--namespace <namespace>`: Executes any command against a specific target project/namespace without switching context.

---

## 4. Kubernetes and OpenShift Resource Manifest Architecture

Every Kubernetes and OpenShift resource manifest consists of structured YAML or JSON object fields:

```
                            ┌────────────────────────────────────────┐
                            │           Resource Manifest            │
                            └───────────────────┬────────────────────┘
                                                │
       ┌───────────────────────┬────────────────┴───────┬───────────────────────┐
       ▼                       ▼                        ▼                       ▼
┌──────────────┐       ┌──────────────┐         ┌──────────────┐        ┌──────────────┐
│  apiVersion  │       │     kind     │         │   metadata   │        │     spec     │
│ (Group/Ver)  │       │(Resource Type│         │(Name/Labels) │        │(Desired State│
└──────────────┘       └──────────────┘         └──────────────┘        └──────────────┘
```

### Common Manifest Fields

| Field Name | Data Type | Purpose & Functionality |
| :--- | :--- | :--- |
| `apiVersion` | `string` | Identifies the schema group and version (e.g., `v1`, `apps/v1`). |
| `kind` | `string` | Defines the REST resource type schema (e.g., `Pod`, `Service`, `Deployment`, `Route`). |
| `metadata.name` | `string` | Unique identifier name for the resource within its namespace. |
| `metadata.namespace`| `string` | Target OpenShift project/namespace hosting the resource. |
| `metadata.labels` | `map[string]string` | Key-value pairs used for organizing, filtering, and connecting resources (e.g., `group: developers`). |
| `spec` | `object` | User-defined **desired state** of the resource (containers, images, environment variables, ports, volume mounts). |
| `status` | `object` | System-generated **actual state** maintained continuously by Kubernetes controllers (conditions, runtime readiness, IP allocations). |

### Core Kubernetes vs. OpenShift Custom Resources

#### 1. Native Kubernetes Resource Types
* **Pod (`pod`)**: Group of co-located containers sharing storage volumes and IP stack.
* **Service (`svc`)**: Internal load balancer providing a stable IP/port endpoint across pod replicas.
* **ReplicaSet (`rs`)**: Guarantees a specified count of pod replicas are running.
* **Deployment (`deploy`)**: Declarative controller managing pod rollouts and ReplicaSet updates.
* **Persistent Volume (`pv`) & Claim (`pvc`)**: Storage volume provisioned in the cluster and requested by pods.
* **ConfigMap (`cm`) & Secret**: Centralized key-value configurations and base64-encoded sensitive credentials.

#### 2. OpenShift-Specific Extensions
* **Build (`build`)**: Execution instance of a container image compilation process.
* **BuildConfig (`bc`)**: Defines build triggers, strategies (S2I, Docker, Pipeline), source Git URL, and target registry output image.
* **Route (`route`)**: Ingress configuration exposing an internal `Service` to external traffic using an HAProxy router hostname.
* **ImageStream (`is`)**: Abstraction tracking container image tags and automated deployment updates.

### Manifest Example & Field Breakdown
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: wildfly
  namespace: my_app
  labels:
    app: wildfly
    group: developers
spec:
  containers:
    - name: wildfly
      image: quay.io/example/todojee:v1
      ports:
        - containerPort: 8080
          name: http
      resources:
        limits:
          cpu: "0.5"
          memory: "512Mi"
      env:
        - name: MYSQL_USER
          value: user1
status:
  conditions:
    - type: PodScheduled
      status: "True"
```

### Label Filtering (`--selector` / `-l`)
Filter resources using key-value labels defined in `metadata.labels`:
```bash
oc get pod --selector group=developers
```

---

## 5. Assessing OpenShift Cluster Health via CLI

To assess the operational health of an OpenShift cluster using CLI tools:

1. **Verify Control Plane Connectivity**:
   ```bash
   oc cluster-info
   ```
2. **Inspect Cluster Operators Status**:
   ```bash
   oc get clusteroperator
   ```
   *Verify that all operators display `AVAILABLE = True`, `PROGRESSING = False`, and `DEGRADED = False`.*

3. **Check Cluster Node Health**:
   ```bash
   oc get nodes
   ```
   *Ensure all control plane and worker nodes show `STATUS = Ready`.*

4. **Audit Core Infrastructure Pods**:
   ```bash
   oc get pods -n openshift-apiserver
   oc get pods -n openshift-authentication
   oc get pods -n openshift-sdn
   ```

5. **Review Project Status Summaries**:
   ```bash
   oc status -n <project_name>
   ```
