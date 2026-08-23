# Chapter 4: Deploy Managed and Networked Applications on Kubernetes

## 1. Kubernetes and OpenShift Application Deployment Overview

Kubernetes and Red Hat OpenShift Container Platform (RHOCP) manage applications as a loose collection of API resource objects. Rather than managing monolithic servers, administrators and developers define declarative configuration manifests that controllers continuously reconcile to maintain desired cluster states.

```
                               ┌────────────────────────────────────────┐
                               │           Application Stack            │
                               └───────────────────┬────────────────────┘
                                                   │
         ┌───────────────────────┬─────────────────┴───────┬───────────────────────┐
         ▼                       ▼                         ▼                       ▼
  ┌──────────────┐       ┌──────────────┐          ┌──────────────┐        ┌──────────────┐
  │  Deployment  │       │   Service    │          │    Secret    │        │     PVC      │
  │ (Pod State)  │       │(Internal IP) │          │(Credentials) │        │ (Storage)    │
  └──────────────┘       └──────────────┘          └──────────────┘        └──────────────┘
```

---

## 2. Standard OpenShift and Kubernetes Resource Types

### Core Resource Definitions

| Resource Type | API Kind | Description & Key Responsibilities |
| :--- | :--- | :--- |
| **Pod** | `v1 Pod` | Smallest compute unit. Consists of one or more co-located containers sharing network namespaces (`localhost`), storage volumes, and IPC. |
| **Deployment** | `apps/v1 Deployment` | Declarative controller managing pod templates, ReplicaSets, rolling updates, scaling, and rollback strategies. |
| **Service** | `v1 Service` | Internal network load balancer. Maps a fixed ClusterIP and port to dynamic pod IP endpoints using label selectors (`spec.selector`). |
| **Route** | `route.openshift.io/v1 Route` | **OpenShift Extension**. Exposes an internal `Service` to external clients outside the cluster via HAProxy router DNS hostnames. |
| **PersistentVolumeClaim** | `v1 PersistentVolumeClaim` | Namespaced request for storage volume binding to a globally-scoped `PersistentVolume` (PV) based on storage class and capacity. |
| **Secret** | `v1 Secret` | Holds sensitive data (passwords, TLS certificates, registry tokens) encoded in base64 (`data`) or plain text (`stringData`). |
| **Project** | `project.openshift.io/v1 Project` | **OpenShift Extension**. Enhanced Kubernetes namespace with multi-tenant RBAC, quota enforcement, and security annotations. |
| **Template** | `template.openshift.io/v1 Template` | **OpenShift Extension**. Parameterized YAML manifest containing definitions of multiple co-dependent application resources. |

---

### Manifest Examples

#### 1. Deployment Specification
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-openshift
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-openshift
  template:
    metadata:
      labels:
        app: hello-openshift
    spec:
      containers:
        - name: hello-openshift
          image: openshift/hello-openshift:latest
          ports:
            - containerPort: 80
```

#### 2. Service Specification
```yaml
apiVersion: v1
kind: Service
metadata:
  name: db-service
  namespace: my-app
spec:
  selector:
    app: mysql-db
  ports:
    - protocol: TCP
      port: 3306
      targetPort: 3306
```

#### 3. Secret Specification
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
  namespace: my-app
type: Opaque
data:
  username: bXl1c2VyCg==    # Base64 encoded "myuser"
  password: bXlQQDU1Cg==    # Base64 encoded "myP@55"
stringData:
  hostname: db.example.com  # Plain text (auto-encoded upon creation)
```

---

## 3. Resource Management Strategies: Imperative vs. Declarative

Resource management in Kubernetes and OpenShift falls into two architectural paradigms:

```
                            ┌────────────────────────────────────────┐
                            │      Resource Management Strategies    │
                            └───────────────────┬────────────────────┘
                                                │
                  ┌─────────────────────────────┴─────────────────────────────┐
                  ▼                                                           ▼
     ┌─────────────────────────┐                                 ┌─────────────────────────┐
     │   Imperative Strategy   │                                 │   Declarative Strategy  │
     ├─────────────────────────┤                                 ├─────────────────────────┤
     │ • Instructs exact CLUSTER│                                 │ • Defines TARGET STATE  │
     │   ACTIONS to perform.   │                                 │   in YAML/JSON files.   │
     │ • Useful for fast, temporary│                                 │ • Essential for GitOps, │
     │   testing/debugging.    │                                 │   versioning & scaling. │
     └─────────────────────────┘                                 └─────────────────────────┘
```

### Imperative Resource Management
Imperative commands explicitly direct the cluster to execute actions without referencing structured version-controlled manifests.

```bash
# Create a deployment imperatively
oc create deployment my-app --image=registry.access.redhat.com/ubi9/httpd-24

# Set environment variables imperatively on an existing deployment
oc set env deployment/my-app TEAM=red

# Run a temporary pod imperatively
oc run temp-pod --image=ubi9 --port=8080 --env GREETING="Hello"

# Generate a dry-run YAML manifest imperatively (without applying to cluster)
oc run example-pod --image=ubi9 --port=8080 --dry-run=client -o yaml > pod-manifest.yaml
```

---

### Declarative Resource Management
Declarative management defines the desired target state in files or templates, allowing OpenShift controllers to automatically bring cluster state into alignment.

```bash
# Declaratively apply/create resources from a manifest file
oc create -f my-app-deployment.yaml
oc apply -f my-app-deployment.yaml

# Declaratively process and inspect an OpenShift Template
oc process -f mysql-template.yaml --parameters
oc process -f mysql-template.yaml -o yaml | oc apply -f -
```

#### OpenShift `oc new-app` Heuristics Engine
The `oc new-app` command uses an intelligent heuristics engine to automatically construct resources based on input parameters:

```bash
# Create resources from a local manifest file
oc new-app --file=./example/my-app.yaml

# Create resources from a pre-defined template with parameter overrides
oc new-app --template=mysql-persistent   -p MYSQL_USER=developer   -p MYSQL_PASSWORD=redhat123   -p DATABASE_SERVICE_NAME=mysql

# Create resources directly from a remote container image
oc new-app --name=db-image --image=registry.access.redhat.com/rhel9/mysql-80:1

# Create resources directly from a Source-to-Image (S2I) Git repository
oc new-app https://github.com/apache/httpd.git#2.4.56
```

---

## 4. Comparing Application Deployment Methods (`oc new-app`)

Deploying applications via **Container Images** versus **OpenShift Templates** yields significantly different default architectures and operational capabilities.

```
                      ┌────────────────────────────────────────┐
                      │    oc new-app Deployment Comparison    │
                      └───────────────────┬────────────────────┘
                                          │
                  ┌───────────────────────┴───────────────────────┐
                  ▼                                               ▼
     ┌─────────────────────────┐                     ┌─────────────────────────┐
     │  Container Image Method │                     │ OpenShift Template Method│
     │   (--image=...)         │                     │   (--template=...)      │
     ├─────────────────────────┤                     ├─────────────────────────┤
     │ • ImageStream           │                     │ • Deployment            │
     │ • Deployment            │                     │ • Service               │
     │ • Service               │                     │ • Secret                │
     │                         │                     │ • PersistentVolumeClaim │
     │ ❌ No Secret            │                     │ • ReadinessProbe        │
     │ ❌ No PVC               │                     │ • Resource Limits (RAM) │
     │ ❌ No ReadinessProbe    │                     │                         │
     │ ❌ No Resource Limits   │                     │                         │
     └─────────────────────────┘                     └─────────────────────────┘
```

### Technical Feature Matrix

| Feature / Resource Component | Container Image Deployment (`--image`) | Template-Based Deployment (`--template`) |
| :--- | :--- | :--- |
| **Deployment Controller** | Yes (`deployment.apps`) | Yes (`deployment.apps`) |
| **Service (Internal Networking)**| Yes (`ClusterIP`) | Yes (`ClusterIP`) |
| **ImageStream** | Yes (`imagestream.image.openshift.io`) | Optional (references target registry image) |
| **Secret Management** | ❌ **No**. Credentials passed as plain-text env vars (`-e`). | **Yes**. Generates base64-encoded `Secret` resources. |
| **Persistent Storage** | ❌ **No**. Ephemeral storage only. | **Yes**. Creates `PersistentVolumeClaim` (PVC). |
| **Health Checks (ReadinessProbe)**| ❌ **No**. Pod becomes `Ready` before service initializes. | **Yes**. Includes health probe (`mysqladmin ping`). |
| **Compute Resource Limits** | ❌ **No**. Unrestricted CPU/RAM usage. | **Yes**. Sets explicit `resources.limits` (e.g., `512Mi`). |

---

## 5. Resource Labeling, Filtering, and Batch Cleanup

### Labels and Selectors
Labels are key-value pairs attached to metadata (`metadata.labels`) used to group, filter, and manage co-dependent resources across a project.

```bash
# Attach labels during application creation
oc new-app --name=mysql --template=mysql-persistent -l team=red
oc new-app --name=db-image --image=mysql-80:1 -l team=blue

# Display resources showing custom label values as columns
oc get pods -L team

# Filter specific resources by label selector
oc get services -l team=red
oc get pods -l deployment=mysql
```

### Label Propagation Warning
When using `-l label=value` with `oc new-app --template`, OpenShift attaches the label to **top-level wrapper resources** (`Deployment`, `Service`, `Secret`, `PVC`), but **does not propagate** the label to inner pod templates unless explicitly defined inside the template manifest.

### Selective Batch Cleanup

```bash
# Delete all standard workload resources matching a label selector
oc delete all -l team=red
```

> **IMPORTANT**: The `oc delete all` command deletes standard workload resources (`Deployment`, `Service`, `Pod`, `ImageStream`), but **omits `Secret` and `PersistentVolumeClaim` (PVC)** resources to protect stateful data. You must delete these stateful resources explicitly:

```bash
# Explicitly delete stateful secrets and persistent volume claims
oc delete secret,pvc -l team=red
```
