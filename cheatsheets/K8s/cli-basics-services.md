# Kubernetes Services Cheatsheet

## What is a Service in Kubernetes?

A **Service** in Kubernetes is an abstraction that defines a logical set of Pods and a policy by which to access them. It allows communication between components inside and outside the cluster.

---

## Service Types

### 1. **ClusterIP** (default)

* Exposes the Service on a cluster-internal IP.
* Only accessible within the cluster.
* Use-case: Internal communication between Pods.

```
kubectl expose deployment myapp --type=ClusterIP --port=80 --target-port=8080
```

### 2. **NodePort**

* Exposes the Service on a static port on each Node's IP.
* Accessible externally via `<NodeIP>:<NodePort>`.
* NodePort range: 30000-32767.

```
kubectl expose deployment myapp --type=NodePort --port=80 --target-port=8080 --name=myapp-service
```

### 3. **LoadBalancer**

* Provisions an external IP address using cloud provider’s load balancer.
* Useful for production environments.

```
kubectl expose deployment myapp --type=LoadBalancer --port=80 --target-port=8080
```

### 4. **ExternalName**

* Maps the service to a DNS name (outside the cluster).
* Doesn't create a proxy.

```
apiVersion: v1
kind: Service
metadata:
  name: my-db
spec:
  type: ExternalName
  externalName: mydb.example.com
```

---

## Inspecting Services

### Get all services

```
kubectl get service
```

Example:

```
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.43.0.1    <none>        443/TCP   33m
```

### Describe a service

```
kubectl describe service kubernetes
```

Output details:

* **Type:** ClusterIP
* **IP:** 10.43.0.1
* **TargetPort:** 6443 (usually maps to Pod container port)
* **Endpoints:** Actual Pod IPs and ports

---

## Creating a Service via YAML

### Deployment

You have a deployment with 4 replicas:

```
kubectl get deploy
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
simple-webapp-deployment   4/4     4            4           11s
```

Pod template selector:

```
Labels: name=simple-webapp
```

### Sample NodePort Service YAML

Filename: `service-definition-1.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
spec:
  type: NodePort
  selector:
    name: simple-webapp
  ports:
    - protocol: TCP
      port: 8080         # Port exposed by the service
      targetPort: 8080   # Port on the Pod
      nodePort: 30080    # Port on the Node (external access)
```

### Apply the YAML

```
kubectl apply -f service-definition-1.yaml
```

### Verify

```
kubectl get svc webapp-service
```

Access externally:

```
http://<NodeIP>:30080
```

---

## Endpoints

Services route traffic to matching **Pod IPs** based on **label selectors**.
You can view endpoints:

```
kubectl get endpoints
```

---

## Debugging Tips

* Ensure Pods have correct labels matching the service selector.
* Check service type and port mappings.
* Verify endpoints are populated.
* Use `kubectl port-forward` for local testing:

```
kubectl port-forward svc/webapp-service 8080:8080
```

---

## Common Commands Recap

| Command                                           | Description                          |
| ------------------------------------------------- | ------------------------------------ |
| `kubectl get svc`                                 | List all services                    |
| `kubectl describe svc <name>`                     | Detailed service info                |
| `kubectl apply -f <file>`                         | Create service from YAML             |
| `kubectl delete svc <name>`                       | Delete a service                     |
| `kubectl get endpoints`                           | See which Pods the service routes to |
| `kubectl port-forward svc/<svc> <local>:<target>` | Forward port for local testing       |

---
