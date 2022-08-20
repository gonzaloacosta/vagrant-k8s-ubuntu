# Observability

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    livenessProbe:
      exec:
        command: [ "ls" ]
```

```bash
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    livenessProbe:
      exec:
        command: [ "ls" ]
      initialDelaySeconds: 5
      periodSeconds: 5
```


```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    livenessProbe:
      httpGet:
        port: 80
        path: "/"
```

```bash
kubectl get events -A | grep -i "Liveness probe failed" | awk '{print $1,$5}'
```

```bash
k run busybox --image=busybox --command -- /bin/sh -c 'i=0 ; while true; do echo "$i: $(date)" ; let "i=i+1"; sleep 1; done'
❯ k logs -f busybox
0: Wed Aug 17 23:44:37 UTC 2022
1: Wed Aug 17 23:44:38 UTC 2022
...
```

```bash
k get event
k delete pod --force
```

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
k top nodes
k top pods
```



