# Configuration

## ConfigMaps

```bash
k create cm config --from-literal=foo=lala --from-literal=foo2=lolo
k get cm -o yaml config
```

```bash
echo "foo3=lili\nfoo4=lele" > config.txt
k create cm config-file --from-file=config.txt
```

```bash
echo -e "var1=val1\n# this is a comment\n\nvar2=val2\n#anothercomment" > config.env
k create cm config.env --from-file=.env=config.env
k get cm config.env -o yaml
```

```bash
k create cm config.env --from-env-file=config.env
```

```bash
echo -e "var3=val3\nvar4=val4" > config4.txt
k create cm config.special --from-file=special=config4.txt
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    env:
    - name: var5
      valueFrom:
        configMapKeyRef:
          name: options
          key: var5
```

```bash
k create configmap anotherone --from-literal=var6=val6 --from-literal=var7=val7
k run --restart=Never nginx --image=nginx -o yaml --dry-run=client > pod.yaml

vi pod.yaml

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    envFrom:
    - configMapRef:
        name: anotherone

k create -f pod.yaml
```

```bash
k run cmvolume --image=nginx --dry-run=client -o yaml > pod2.yaml

vi pod2.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: cmvolume
  name: cmvolume
spec:
  volumes:
  - name: cmvolume
    configMap:
      name: cmvolume
  containers:
  - image: nginx
    name: cmvolume
    volumeMounts:
    - name: cmvolume
      mountPath: /etc/lala

k create -f pod2.yaml

k exec cmvolume -- ls /etc/lala
```

- Security Context

```bash
❯ cat pod-sc.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  securityContext:
    runAsUser: 101
  containers:
  - name: nginx
    image: nginx
```

- Capabilities

```bash
❯ cat pod-cap.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      capabilities:
        add: ["NET_ADMIN", "SYS_TIME"]
```

- Resource limits

```bash
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources:
      limits:
        memory: 512Mi
        cpu: 200m
      requests:
        memory: 256Mi
        cpu: 100m
```

- Secrets

```bash
k create secret generic mysecret --from-literal=password=mypass
```

```bash
echo -n admin > username
k create secret generic mysecret2 --from-file=username
```

```bash
kubectl get secret mysecret2 -o jsonpath='{.data.username}' | base64 -d
```

```bash
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  volumes:
  - name: secret
    secret:
      secretName: mysecret2
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
    - name: secret
      mountPath: /etc/foo
```

```bash
❯ cat pod-secret-env.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    env:
    - name: USERNAME
      valueFrom:
        secretKeyRef:
          name: mysecret2
          key: username
```

- Service Account

```bash
kubectl create sa myuser
kubectl run nginx --image=nginx --restart=Never -o yaml --dry-run=client > pod.yaml
vi pod.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx
  name: nginx
spec:
  serviceAccountName: myuser
  containers:
  - image: nginx
    name: nginx
```

