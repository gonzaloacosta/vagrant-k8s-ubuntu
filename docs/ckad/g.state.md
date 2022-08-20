# State

```bash
k run busybox --image=busybox -o yaml --dry-run=client -- /bin/sh -c 'sleep 3600' > pod.yaml
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: busybox
  name: busybox
spec:
  volumes:
  - name: shared
    emptyDir: {}
  containers:
  - image: busybox
    name: busybox
    command:
    - /bin/sh
    - -c
    - sleep 3600
    volumeMounts:
    - name: shared
      mountPath: /etc/foo
  - image: busybox
    name: busybox2
    command:
    - /bin/sh
    - -c
    - sleep 3600
    volumeMounts:
    - name: shared
      mountPath: /etc/foo
```

```bash
k create -f pod.yaml
k exec -it busybox -c busybox2 -- /bin/bash
# cat /etc/passwd | cut -d ":" -f 1 > /etc/foo/passwd
# exit


k exec -it busybox -c busybox -- cat /etc/foo/passwd
```

```bash
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
