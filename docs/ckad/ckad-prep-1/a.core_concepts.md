# CKAD Core Concepts

```bash
export CKAD=/home/gonza/vagrant/k8s_ubuntu/dosc/ckad/
mkdir -p $CKAD
```

```bash
k create ns mynamespace
k run nginx --image=nginx -n mynamespace
k get pods -n mynamespace
k delete pod --force -n mynamespace nginx
k delete ns mynamespace
```

```bash
k run nginx --image=nginx -n mynamespace -o yaml --dry-run=client > nginx.yaml
k apply -f nginx.yaml
k delete -f nginx.yaml
```

```bash
k run busybox --image=busybox -n mynamespace -o yaml --dry-run=client --command env > busybox.yaml
k create -f busybox.yaml
```

```bash
k create ns myns --dry-run=client -o yaml > myns.yaml
```

```bash
k create quota myrq --hard=cpu=1,memory=1G,pods=2 --dry-run=client -o yaml > myrq.yaml

cat myrq.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  creationTimestamp: null
  name: myrq
spec:
  hard:
    cpu: "1"
    memory: 1G
    pods: "2"
status: {}
```

```bash
k get pods -A
```

```bash
k run nginx --image=nginx --port=80 ; k expose pod nginx --port 80 --target-port 80 --type ClusterIP
k run mypod --image=nginx ; sleep 30 ; k exec -it mypod -- curl http://nginx
```

```bash
k set image pod/nginx nginx=nginx:1.7.1
k describe pod nginx
kubectl get po nginx -o jsonpath='{.spec.containers[].image}{"\n"}'
```

```bash
k run busybox --image=busybox --rm -it --restart=Never -- wget $(kubectl get po nginx -o jsonpath='{.status.podIP}')
```

```bash
k logs nginx -p
k logs nginx --previus
```

```bash
kubectl exec -it nginx -- /bin/sh
```

```bash
k run busybox --image=busybox --rm -it --restart=Never -- echo "hello world"
kubectl run busybox --image=busybox -it --rm --restart=Never -- /bin/sh -c 'echo hello world'
```

```bash
k run nginx --image=nginx --restart=Never --rm -it --env var1=val1 --command -- /bin/sh -c 'env | grep var1'
```
