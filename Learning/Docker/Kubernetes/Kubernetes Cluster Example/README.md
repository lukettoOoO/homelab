# Kubernetes Cluster Example

## Running a Kubernetes cluster in my local environment

- Installing `kubectl` (sends commands to the API server) and `minikube` (the engine that will run a cluster with a single node):
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64\n
sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64\n
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version

minikube start --driver=docker
```
- Minikube downloads a special base image (which contains the Control Plane, Kubelet and all the dependencies), will configure internal networks and will automatically set the configuration file for kubectl
```bash
minikube start --driver=docker
😄  minikube v1.38.1 on Debian 13.6
✨  Using the docker driver based on user configuration
❗  Starting v1.39.0, minikube will default to "containerd" container runtime. See #21973 for more info.
📌  Using Docker driver with root privileges
👍  Starting "minikube" primary control-plane node in "minikube" cluster
🚜  Pulling base image v0.0.50 ...
💾  Downloading Kubernetes v1.35.1 preload ...
    > preloaded-images-k8s-v18-v1...:  272.45 MiB / 272.45 MiB  100.00% 1.81 Mi
    > gcr.io/k8s-minikube/kicbase...:  519.58 MiB / 519.58 MiB  100.00% 2.74 Mi
🔥  Creating docker container (CPUs=2, Memory=3072MB) ...
🐳  Preparing Kubernetes v1.35.1 on Docker 29.2.1 ...
🔗  Configuring bridge CNI (Container Networking Interface) ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: default-storageclass, storage-provisioner
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```
- Inspecting the cluster:
```bash
# luca @ debian-eos in /srv [16:20:51] 
$ kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   47m   v1.35.1
```
Minikube quick start: https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Fx86-64%2Fstable%2Fbinary+download#Service

| Category | Command | Description |
| :--- | :--- | :--- |
| **Autocomplete & Global** | `source <(kubectl completion zsh)` | Sets up autocomplete in the current Zsh shell. |
| | `kubectl -A` | Shorthand flag to run a command across all namespaces. |
| **Context & Configuration** | `kubectl config get-contexts` | Displays a list of all available contexts. |
| | `kubectl config current-context` | Displays the current active context. |
| | `kubectl config use-context <name>` | Sets the default context to the specified cluster context. |
| | `kubectl config set-context --current --namespace=<ns>` | Permanently saves a namespace for subsequent commands in the active context. |
| **Creating & Applying** | `kubectl apply -f ./manifest.yaml` | Creates or updates resource(s) from a local YAML file. |
| | `kubectl create deployment nginx --image=nginx` | Starts a single instance of an Nginx deployment. |
| | `kubectl explain pods` | Retrieves interactive documentation for Pod manifest schemas. |
| **Viewing Resources** | `kubectl get pods -o wide` | Lists all Pods in the current namespace with detailed info (like Node and IP). |
| | `kubectl describe pods <pod-name>` | Shows verbose, detailed status and events of a specific Pod. |
| | `kubectl get pods --field-selector=status.phase=Running` | Lists only the Pods that are currently in a running phase. |
| | `kubectl get nodes -o custom-columns='NAME:.metadata.name,STATUS:.status.conditions[?(@.type=="Ready")].status'` | Lists nodes with their custom readiness status columns. |
| **Updating & Rollouts** | `kubectl set image deployment/frontend www=image:v2` | Performs a rolling update to update the container image of a deployment. |
| | `kubectl rollout history deployment/frontend` | Checks the revision deployment history. |
| | `kubectl rollout undo deployment/frontend` | Rolls back the deployment to its previous revision. |
| | `kubectl label pods <pod-name> new-label=value` | Adds a new label to a specific Pod. |
| **Patching & Scaling** | `kubectl scale --replicas=3 deployment/mysql` | Scales the specified deployment's replica count to 3. |
| | `kubectl patch node <node-name> -p '{"spec":{"unschedulable":true}}'` | Partially updates a node's specification to make it unschedulable. |
| **Deleting Resources** | `kubectl delete pod <pod-name> --now` | Deletes a Pod immediately with no grace period. |
| | `kubectl delete pods,services -l name=myLabel` | Deletes all Pods and Services matching a specific label. |
| **Interacting with Pods** | `kubectl logs -f <pod-name>` | Streams the stdout logs of a running Pod. |
| | `kubectl run -i --tty busybox --image=busybox -- sh` | Spawns and attaches to an interactive terminal shell inside a temporary Pod. |
| | `kubectl exec -it <pod-name> -- /bin/sh` | Opens an interactive shell session inside an already running Pod container. |
| | `kubectl port-forward <pod-name> 5000:6000` | Forwards local port 5000 to port 6000 on the specified target Pod. |
| | `kubectl top pod` | Shows CPU and memory metrics for all Pods in the namespace. |
| **Node Management** | `kubectl drain <node-name>` | Evicts and drains all workloads from a node safely for maintenance. |
| | `kubectl uncordon <node-name>` | Marks a node back as schedulable. |
| **API Exploration** | `kubectl api-resources` | Lists all supported API resource types along with their shortnames and groups. |
