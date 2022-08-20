# Services and Networking

```bash
k run nginx --image=nginx --port=80
k expose pod/nginx --port=80 --target-port=80 --type=ClusterIp
k get svc nginx -o jsonpath='{.spec.type}'
```

```bash
k run busybox --image=busybox -- sleep 10000
k exec -it busybox -- wget -O- http://$(k get svc nginx -o jsonpath="{.spec.clusterIP}")
```

```bash
k delete svc nginx
k expose pod/nginx --port=80 --target-port=80 --type=NodePort
k get nodes
curl http://<node>:<port_30000>
```

```bash
k create deploy foo --image=dgkanatsios/simpleapp --replicas 3 --port=8080
```

```bash
kubectl create deployment nginx --image=nginx --replicas=2
kubectl expose deployment nginx --port=80

kubectl get svc nginx -o yaml

vi policy.yaml

kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: access-nginx # pick a name
spec:
  podSelector:
    matchLabels:
      app: nginx # selector for the pods
  ingress: # allow ingress traffic
  - from:
    - podSelector: # from pods
        matchLabels: # with this label
          access: granted

k create -f policy.yaml

k run busybox --image=busybox --rm -it --restart=Never -- wget -O- http://nginx:80 --timeout 2

k run busybox --image=busybox --rm -it --restart=Never --labels=access=granted -- wget -O- http://nginx:80 --timeout 2
````
