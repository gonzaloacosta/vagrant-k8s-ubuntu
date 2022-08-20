# Pod Design

```bash
for i in $(seq 1 3); do k run nginx$i --image=nginx --labels=app=v1 ; done

k get pods -l app=v1
NAME     READY   STATUS    RESTARTS   AGE
nginx1   1/1     Running   0          26s
nginx2   1/1     Running   0          26s
nginx3   1/1     Running   0          26s
```

```bash
k label pod/nginx2 --overwrite app=v2
```

```bash
k get pod -l app -o custom-columns=POD:.metadata.name,APP:.metadata.labels
k get pods -l app=v1
k get pods -l app=v2
```

```bash
k label pod -l app=v1 tier=web
k label pod -l app=v2 tier=web
```

```bash
k annotate pod -l app=v2 owner=marketing
```

```bash
k delete pod --force -l app=v1 
k delete pod --force -l app=v2 
```

```bash
k taint nodes kworker1 app=blue:NoSchedule-
```

```bash
k label node kworker1 accelerator=nvidia-tesla-p100

k run cuda --image=k8s.gcr.io/cuda-vector-add:v0.1 > gpu.yaml

vi gpu.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: cuda
  name: cuda
spec:
  nodeSelector:
    accelerator: nvidia-tesla-p100
  containers:
  - image: "k8s.gcr.io/cuda-vector-add:v0.1" 
    name: cuda
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}

k create -f cuda.yaml

k get pod cuda -o jsonpath='{.spec.nodeName}'
```

```bash
# or use nodeAffinity

vi cuda.yaml
apiVersion: v1
kind: Pod
metadata:
  name: cuda-affinity-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: accelerator
            operator: In
            values:
            - nvidia-tesla-p100
  containers:
  ...
```

```bash
k annotate pod nginx{1..3} description='my description'
k annotate pod nginx1 --list
```

## Deployments

```bash
k create deploy nginx --image=nginx:1.18.0 --port=80 --replicas=2
k get deploy nginx -o yaml
k get pods -l app=nginx
k get deploy nginx
```

```bash
k rollout status deploy nginx
k set image deploy nginx nginx=nginx:1.19.8
k rollout history deploy nginx
k rollout undo deploy/nginx --dry-run=server -o jsonpath='{.spec.template.spec.containers[0].image}'
k rollout undo deploy/nginx
k rollout undo deploy/nginx --to-revision=1
```

```bash
k set image deploy nginx nginx=nginx:19191919
k rollout status deploy nginx -w
>> fail with ErrorImagePull
k rollout undo deploy nginx
k rollout history deploy nginx --revision=3
```

```bash
k autoscale deploy nginx --max=10 --min=5 --cpu-percent=80
k rollout pause deploy nginx
k rollout status deploy nginx
Waiting for deployment "nginx" rollout to finish: 0 out of 5 new replicas have been updated...
k rollout resume deploy nginx
Waiting for deployment "nginx" rollout to finish: 3 out of 5 new replicas have been updated...
```

### Canary

- v1

```bash
vi app-v1.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: myapp
  name: myapp-v1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: v1
  template:
    metadata:
      labels:
        app: myapp
        version: v1
    spec:
      containers:
      - image: nginx
        name: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: workdir
          mountPath: "/usr/share/nginx/html"
      initContainers:
      - image: busybox
        name: install
        volumeMounts:
        - name: workdir
          mountPath: "/work-dir"
        command:
        - /bin/sh
        - -c
        - "echo version-1 > /work-dir/index.html"
      volumes:
      - name: workdir
        emptyDir: {}
```

- service

```
k create service clusterip my-app --tcp=80:80 --dry-run=client -o yaml > myapp-svc.yaml

k create -f myapp-svc.yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: myapp
  name: myapp
spec:
  ports:
  - name: 80-80
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: myapp
  type: ClusterIP
status:
  loadBalancer: {}
```

- v2

```bash
vi app-v1.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: myapp
  name: myapp-v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
      version: v1
  template:
    metadata:
      labels:
        app: myapp
        version: v1
    spec:
      containers:
      - image: nginx
        name: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: workdir
          mountPath: "/usr/share/nginx/html"
      initContainers:
      - image: busybox
        name: install
        volumeMounts:
        - name: workdir
          mountPath: "/work-dir"
        command:
        - /bin/sh
        - -c
        - "echo version-1 > /work-dir/index.html"
      volumes:
      - name: workdir
        emptyDir: {}
```

```bash
k scale deploy myapp-v1 --replicas=4
k scale deploy myapp-v2 --replicas=1

k run test --image=nginx
while sleep 0.5 ; do k exec -it test -- curl $(k get svc myapp -o jsonpath='{.spec.clusterIP}') ; done

if it's ok with v2

k scale deploy myapp-v1 --replicas=0
k scale deploy myapp-v2 --replicas=3

while sleep 0.5 ; do k exec -it test -- curl $(k get svc myapp -o jsonpath='{.spec.clusterIP}') ; done
```

## Jobs

```bash
k create job pi --image=perl:5.34 --dry-run=client -o yaml -- /bin/sh -c "perl -Mbignum=bpi -wle 'print bpi(2000)'" > job.yaml

vi job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  creationTimestamp: null
  name: pi
spec:
  template:
    metadata:
      creationTimestamp: null
    spec:
      containers:
      - command:
        - /bin/sh
        - -c
        - perl -Mbignum=bpi -wle 'print bpi(2000)'
        image: perl:5.34
        name: pi
        resources: {}
      restartPolicy: Never
status: {}

k create -f job.yaml
```

```bash
k craete job hello -- /bin/sh -c 'echo hello;sleep 30;echo world'
k describe job hello
k delete job hello pi
```

```bash
k create job job-delete --image=busybox --dry-run=client -o yaml  -- /bin/sh -c 'echo "run sleep"; sleep 45; echo "finish sleep"' > job-delete.yaml

k explain job.spec.activeDeadlineSeconds

vi job-delete.yaml

apiVersion: batch/v1
kind: Job
metadata:
  creationTimestamp: null
  name: job-delete
spec:
  activeDeadlineSeconds: 30
  template:
    metadata:
      creationTimestamp: null
    spec:
      containers:
      - command:
        - /bin/sh
        - -c
        - echo "run sleep"; sleep 45; echo "finish sleep"
        image: busybox
        name: job-delete
        resources: {}
      restartPolicy: Never
status: {}

k create -f job-delete.yaml

k describe job job-delete
```

```bash
k explain job.spec.completions

vi job-completions.yaml

apiVersion: batch/v1
kind: Job
metadata:
  name: job-completions
spec:
  completions: 5
  template:
    metadata:
    spec:
      containers:
      - command:
        - /bin/sh
        - -c
        - echo hello; sleep 10; echo world
        image: busybox
        name: job-completions
```

```bash
apiVersion: batch/v1
kind: Job
metadata:
  name: job-parallelims
spec:
  completions: 5
  parallelism: 5
  template:
    metadata:
      creationTimestamp: null
    spec:
      containers:
      - command:
        - /bin/sh
        - -c
        - echo hello;sleep 10;echo world
        image: busybox
        name: job-parallelims
        resources: {}
      restartPolicy: Never
status: {}
```

## Cronjobs

```bash
k create cronjob my-job --image=busybox --schedule="*/1 * * * *" -- /bin/sh -c 'date;echo Hello from the Kubernetes cluster'
k get cj
k get jobs --watch
k get po --show-labels 
k logs my-job-1529745840-m867r
k delete cj my-job
```

```bash
k explain cronjob.spec.startingDeadlineSeconds
k explain cronjob.spec.activeDeadlineSeconds
```
