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


