# Kubernetes CLI Cheatsheet

## 🔍 Get Cluster Information

### Check cluster info:

```bash
kubectl cluster-info
```

> Displays master and services info. Useful to verify if the cluster is reachable.

### View current context:

```bash
kubectl config current-context
```

> Shows which cluster configuration kubectl is using.

### List all contexts:

```bash
kubectl config get-contexts
```

> Shows available contexts and lets you switch between clusters.

### Switch context:

```bash
kubectl config use-context <context-name>
```

> Switches to a different Kubernetes context.

## 🧠 Nodes

### List nodes:

```bash
kubectl get nodes
```

> Shows all nodes in the cluster with their statuses and roles.

### Describe node:

```bash
kubectl describe node <node-name>
```

> Detailed information about a node, including allocated resources, labels, conditions.

## 📦 Pods

### List all pods in a namespace:

```bash
kubectl get pods -n <namespace>
```

> Shows pod names, status, restarts, age. Omit `-n` for the default namespace.

### List pods in all namespaces:

```bash
kubectl get pods --all-namespaces
```

### Describe a pod:

```bash
kubectl describe pod <pod-name> -n <namespace>
```

> Details like events, container states, IP, volumes.

### Get pod logs:

```bash
kubectl logs <pod-name>
```

> Outputs logs from the first container in the pod.

### Logs from a specific container:

```bash
kubectl logs <pod-name> -c <container-name>
```

### Follow logs (like `tail -f`):

```bash
kubectl logs -f <pod-name>
```

### Execute command in a running pod:

```bash
kubectl exec -it <pod-name> -- /bin/bash
```

> Opens interactive shell inside a container (if bash is available).

### Port-forward a pod to localhost:

```bash
kubectl port-forward <pod-name> <local-port>:<pod-port>
```

> Makes a pod's port accessible locally.

## 📂 Deployments & ReplicaSets

### List deployments:

```bash
kubectl get deployments
```

### Create deployment:

```bash
kubectl create deployment <name> --image=<image>
```

### Scale deployment:

```bash
kubectl scale deployment <name> --replicas=<num>
```

### View ReplicaSets:

```bash
kubectl get rs
```

### Describe deployment:

```bash
kubectl describe deployment <name>
```

### Update deployment image:

```bash
kubectl set image deployment/<name> <container-name>=<new-image>
```

## 🔁 Rollouts & Rollbacks

### Check rollout status:

```bash
kubectl rollout status deployment/<name>
```

### Rollback to previous version:

```bash
kubectl rollout undo deployment/<name>
```

## 📜 YAML Manifests

### Apply a YAML file:

```bash
kubectl apply -f <file>.yaml
```

> Used for create/update declaratively.

### Delete using YAML:

```bash
kubectl delete -f <file>.yaml
```

### Dry-run mode:

```bash
kubectl apply -f <file>.yaml --dry-run=client
```

> Validates the file without making changes.

### Sample Deployment YAML:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2
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

## 🧪 Services

### List services:

```bash
kubectl get svc
```

### Expose a deployment as service:

```bash
kubectl expose deployment <deployment-name> --type=NodePort --port=<port>
```

## 🔍 Namespaces

### List all namespaces:

```bash
kubectl get namespaces
```

### Create a namespace:

```bash
kubectl create namespace <name>
```

### Delete a namespace:

```bash
kubectl delete namespace <name>
```

## 🔒 Secrets & ConfigMaps

### Create a secret from literals:

```bash
kubectl create secret generic <name> --from-literal=key=value
```

### Create a configmap from file:

```bash
kubectl create configmap <name> --from-file=<filename>
```

### Get configmap/secret:

```bash
kubectl get configmap <name> -o yaml
kubectl get secret <name> -o yaml
```

> Note: Secret values are base64-encoded.

### Decode a base64 secret value:

```bash
echo <base64-value> | base64 --decode
```

## 🧹 Cleanup & Debug

### Delete a pod:

```bash
kubectl delete pod <pod-name>
```

### Force delete:

```bash
kubectl delete pod <pod-name> --grace-period=0 --force
```

### View events:

```bash
kubectl get events --sort-by='.metadata.creationTimestamp'
```

### View resources with wide output:

```bash
kubectl get pods -o wide
```

## 📄 Miscellaneous

### Get YAML of a live object:

```bash
kubectl get pod <pod-name> -o yaml
```

### Convert YAML to JSON:

```bash
kubectl get -o json <resource>
```

### Apply multiple files:

```bash
kubectl apply -f dir/
```

### Get API resources:

```bash
kubectl api-resources
```

### Explain a resource:

```bash
kubectl explain pod
kubectl explain deployment.spec.template
```

> Great for learning resource structure

## 🛠 Useful Shortcuts

```bash
k get po                        # Get pods
k get svc                       # Get services
k get deploy                    # Get deployments
k describe po <pod>             # Describe a pod
k logs <pod>                    # Pod logs
k exec -it <pod> -- bash        # Shell in pod
```

Where `k` is an alias:

```bash
alias k=kubectl
```

---
