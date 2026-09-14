# Kubernetes Infrastructure

- Kubernetes works with objects
- A deployment is a K8 object which assures that a certain number of identical pods run in a cluster. If one pod dies, the deployment will recreate it instantly.
- Every Kubernetes configuration file is split into 4 required sections:
     - `apiVersion`: the API version that we use (tells K8s how to read the file)
     - `kind`: what kind of object will be created (pod, deployment, service, etc.)
        - `kind: Pod`: a single instance of a running processs (containing one or more containers); ephemeral, if a pod dies it stays dead; bare pods are rarely created in production
        - `kind: Deployment`: manager for pods; provides declarative updates, automatically replaces dead pods, and allows us to easily scale our application up or down
        - `kind: StatefulSet`: like a deployment, but for applications that need to remember who they are (databases, key-value stores)
        - `kind: Service`: an abstraction layer that defines a logical set of pods and a policy to access them; because pods are constantly dying and being recreated by deployments, their IP addresses change; a service gives us a permanent IP address and DNS name to talk to those pods, acting as a built-in load balancer
        - `kind: ConfigMap`, `kind: Secret`: objects used to inject configuration data into our pods; `ConfigMap` is for plain-text configuration (like environment variables or config files); `Secret` is specifically for sensitive data (passwords, tokens, keys) and is encrypted
     - `metadata`: the name of the object and the labels we assign to it
     - `spec`: the technical specification - what we want inside (how many replicas, Docker images, etc.)
- Kubernetes uses labels to identify objects
- Example:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```
```bash
kubectl apply -f nginx-deployment.yaml
kubectl get deployments
kubectl rollout status deployment/nginx-deployment
kubectl get rs
kubectl get pods --show-labels
```
-  *A Deployment's rollout is triggered if and only if the Deployment's Pod template (that is, `.spec.template`) is changed*
```bash
kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.16.1
kubectl edit deployment/nginx-deployment
kubectl rollout status deployment/nginx-deployment
```
- A deployment's label selector is **immutable** after creation
- Rollback after having issues with a deployment:
```bash
kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.161 # mistake
kubectl rollout status deployment/nginx-deployment # this keeps looping
kubectl get rs
kubectl get pods
kubectl describe deployment
kubectl rollout history deployment/nginx-deployment
kubectl rollout history deployment/nginx-deployment --revision=3
kubectl rollout undo deployment/nginx-deployment
kubectl get deployment nginx-deployment
```
- Scaling a deployment:
```bash
kubectl scale deployment/nginx-deployment --replicas=10
kubectl autoscale deployment/nginx-deployment --min=10 --max=15 --cpu-percent=80
```
- Proportional scaling:
```bash
kubectl get deploy
kubectl set image deployment/nginx-deployment nginx=nginx:sometag # unresolvable image
kubectl get rs
kubectl get deploy
```
- Pausing and resuming a rollout of a deployment (to apply multiple fixes at once, for example):
```bash
kubectl get deploy
kubectl get rs
kubectl rollout pause deployment/nginx-deployment
kubectl set image deployment/nginx-deployment nginx=nginx:1.16.1
kubectl rollout history deployment/nginx-deployment
kubectl get rs
kubectl set resources deployment/nginx-deployment -c=nginx --limits=cpu=200m,memory=512Mi
kubectl rollout resume deployment/nginx-deployment
```
- Checking if a deployment has been completed:
```bash
kubectl rollout status deployment/nginx-deployment
echo $?
```
- *The following kubectl command sets the spec with `progressDeadlineSeconds` to make the controller report lack of progress of a rollout for a Deployment after 10 minutes:*
```bash
kubectl patch deployment/nginx-deployment -p '{"spec":{"progressDeadlineSeconds":600}}'
```
- Clean up Policy: *You can set .spec.revisionHistoryLimit field in a Deployment to specify how many old ReplicaSets for this Deployment you want to retain. The rest will be garbage-collected in the background. By default, it is 10.*

## Writing a Deployment Spec
**A Kubernetes Deployment specification configures how the control plane creates, scales, updates, and manages a group of identical Pods.**

- **Required Specification Fields:** Every Deployment `.spec` requires a `.spec.template` (the Pod configuration) and a `.spec.selector` (labels used to target and manage its Pods).
- **Pod Template Constraints:** The Pod template requires a `.spec.restartPolicy` of `Always` and must define labels that match the `.spec.selector` exactly to avoid API rejection or controller conflicts.
- **Scaling (`.spec.replicas`):** Defines the desired Pod count (defaults to 1). Manual updates via `kubectl apply` overwrite manual CLI scaling, and this field should be omitted if using an autoscaler like HPA.
- **Update Strategies (`.spec.strategy`):** 
  - **`RollingUpdate` (Default):** Replaces Pods incrementally using `maxSurge` (extra Pods allowed above target) and `maxUnavailable` (max Pods down during update).
  - **`Recreate`:** Terminates all old Pods before starting new ones.
- **Timing & Status Configurations:**
  - **`minReadySeconds`:** How long a new Pod must run without crashing before it is considered available (defaults to 0).
  - **`progressDeadlineSeconds`:** Max seconds to wait for rollout progress before marking it failed (defaults to 600).
- **Lifecycle & Maintenance:**
  - **`revisionHistoryLimit`:** Number of old ReplicaSets retained for rollbacks (defaults to 10; setting to 0 disables rollbacks).
  - **`paused`:** Pauses rollouts so changes to the Pod template won't trigger immediate updates.
  - **Terminating Pods:** Tracked via `.status.terminatingReplicas` to monitor resource usage during scale-down.