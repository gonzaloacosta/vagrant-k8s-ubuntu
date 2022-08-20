# Multi Container Pods

```bash
k run multi --image=busybox --dry-run=client -o yaml --command -- /bin/sh -c "echo hello;sleep 3600" > multi.yaml

vi multi.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: multi
  name: multi
spec:
  containers:
  - command:
    - /bin/sh
    - -c
    - echo hello;sleep 3600
    image: busybox
    name: c1
  - command:
    - /bin/sh
    - -c
    - echo hello;sleep 3600
    image: busybox
    name: c2

k create -f multi.yaml

k exec -it multi -c c2 ls
```

```bash

k run nginx --image=nginx --dry-run=client -o yaml > multi2.yaml

vi multi2.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  initContainers:
  - image: busybox
    name: busybox
    command:
    - /bin/sh
    - -c
    - wget -O /work-dir/index.html http://neverssl.com/online
    volumeMounts:
    - name: share
      mountPath: /work-dir/
  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80
    volumeMounts:
    - name: share
      mountPath: /work-dir/
  volumes:
  - name: share
    emptyDir: {}

k create -f multi2.yaml

k run busybox --rm -it --restart=Never --image=busybox --command -- wget -O- $(k get pod nginx -o jsonpath='{.status.podIP}')
```


