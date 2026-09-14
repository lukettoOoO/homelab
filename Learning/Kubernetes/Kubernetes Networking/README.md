# Kubernetes Networking

## Services in Kubernetes
- *The Service API, part of Kubernetes, is an abstraction to help you expose groups of Pods over a network. Each Service object defines a logical set of endpoints (usually these endpoints are Pods) along with a policy about how to make those pods accessible.*
- The set of pods targeted by a service is usually determined by a defined selector

### Defining a Service
- A service is an object
- Example for a set of pods that each listen on TCP port 9376 and are labelled as `app.kubernetes.io/name=MyApp`; a service is defined to publish the TCP listener:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app.kubernetes.io/name: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
# This service targets TCP port 9376 on any pod with the app.kubernetes.io/name:MyApp label
```

### Port definitions
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app.kubernetes.io/name: proxy
  ports:
  - name: name-of-service-port
    protocol: TCP
    port: 80
    targetPort: http-web-svc # target port declared here

---
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app.kubernetes.io/name: proxy
spec:
  containers:
  - name: nginx
    image: nginx:stable
    ports:
      - containerPort: 80
        name: http-web-svc # target port referenced here
```

### Services without selectors
- Kubernetes Services without selectors route traffic to custom network targets—including external backends outside the cluster—by using manually defined EndpointSlices instead of automatic Pod discovery.

- Use Cases
    - **External Databases:** Connecting cluster workloads to external database clusters.
    - **Cross-Cluster/Namespace Routing:** Directing traffic to a Service in a different namespace or cluster.
    - **Phased Migrations:** Routing a portion of traffic to legacy infrastructure while migrating workloads to Kubernetes.

1. Create a Service without a `spec.selector` field.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 9376
```
2. Manually create `EndpointSlice` manifests containing the target IP addresses and ports.
3.  Attach the label `kubernetes.io/service-name: <service-name>` to the `EndpointSlice` to pair it with the Service.
```yaml
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: my-service-1 # by convention, use the name of the Service
                     # as a prefix for the name of the EndpointSlice
  labels:
    # You should set the "kubernetes.io/service-name" label.
    # Set its value to match the name of the Service
    kubernetes.io/service-name: my-service
addressType: IPv4
ports:
  - name: http # should match with the name of the service port defined above
    appProtocol: http
    protocol: TCP
    port: 9376
endpoints:
  - addresses:
      - "10.4.5.6"
  - addresses:
      - "10.1.2.3"
```

- Endpoints cannot use loopback addresses (`127.0.0.0/8`, `::1/128`), link-local addresses, or Cluster IPs of other Services.
- Custom slices should set the `endpointslice.kubernetes.io/managed-by` label to identify who manages them (e.g., `staff` or `cluster-admins`). Avoid the reserved `controller` label.
- Features like `kubectl port-forward` will fail on selectorless Services because the API server blocks proxying to endpoints not mapped to Pods.
- EndpointSlices break large lists of endpoints into smaller, manageable chunks.
- Kubernetes automatically generates a new slice once existing slices reach **100 endpoints**.

### Service types
- **ClusterIP (Default):** Exposes the Service on an internal IP address within the cluster, making it accessible only from inside the cluster unless paired with an Ingress or Gateway.
- **Headless Service:** Created by setting `.spec.clusterIP: "None"`, preventing Kubernetes from assigning an internal IP address.
- **NodePort:** Exposes the Service on each Node's IP at a static port (default range: 30000–32767), automatically building on top of a ClusterIP to route external traffic to internal endpoints.
- **NodePort Port Reservation:** To minimize collisions, the default port range is split into a static band (30000–30085) for manual assignments and a dynamic band (30086–32767) for automatic allocations.
- **LoadBalancer:** Provisioned via a cloud provider's external load balancer to direct traffic to backend Pods, automatically configuring NodePort and ClusterIP underneath unless explicitly disabled.
- **LoadBalancer Class & Customization:** Allows custom implementations via `.spec.loadBalancerClass`, protocol mixing on multiple ports, and disabling NodePort allocation via `spec.allocateLoadBalancerNodePorts: false`.
- **ExternalName:** Maps a Kubernetes Service directly to an external DNS CNAME record (e.g., an external database) without using proxies, IP addresses, or selectors.

## DNS for Services and Pods
- Kubernetes automatically handles DNS resolution for Services and Pods, allowing workloads to discover each other using predictable domain names.

- **Service DNS Records:**
  - **ClusterIP Services:** Map `my-svc.my-namespace.svc.cluster.local` directly to the Service's cluster IP.
  - **Headless Services (`clusterIP: None`):** Resolve the Service domain name directly to the group of individual backend Pod IPs.
  - **SRV Records:** Generated for named ports using the format `_port-name._port-protocol.my-svc.my-namespace.svc.cluster.local`.

- **Pod DNS & Hostnames:**
  - **IP-Based DNS:** Pod IPs are assigned DNS records formatted as `172-17-0-3.my-namespace.pod.cluster.local`.
  - **Custom Hostnames & Subdomains:** When a Pod defines a `hostname` and a `subdomain` matching a Headless Service name, it generates a fully qualified domain name (FQDN).
  - **`setHostnameAsFQDN`:** When set to `true`, writes the complete FQDN to the Pod's kernel hostname (limited to 64 characters).

- **Pod DNS Policies (`dnsPolicy`):**
  - **`ClusterFirst` (Default):** Route intra-cluster DNS queries to the cluster DNS server and forward external queries upstream.
  - **`ClusterFirstWithHostNet`:** Required for Pods using `hostNetwork: true` to preserve cluster DNS discovery.
  - **`Default`:** Causes the Pod to inherit the node's underlying DNS configuration.
  - **`None`:** Ignores Kubernetes cluster DNS settings completely, requiring manual setup in `dnsConfig`.

- **Custom DNS Configurations (`dnsConfig`):** Allows custom nameservers, search domains, and options (such as `ndots`).

---

### Example Manifest: Headless Service with Subdomain Pods

```yaml
apiVersion: v1
kind: Service
metadata:
  name: busybox-subdomain
spec:
  clusterIP: None
  selector:
    app: busybox
  ports:
    - name: http
      port: 80
---
apiVersion: v1
kind: Pod
metadata:
  name: busybox1
  labels:
    app: busybox
spec:
  hostname: busybox-1
  subdomain: busybox-subdomain
  containers:
    - name: busybox
      image: busybox:1.28
      command: ["sleep", "3600"]
```