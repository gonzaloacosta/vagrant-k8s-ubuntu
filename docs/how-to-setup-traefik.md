# Deploy traefik

```
❯ pyfiglet -j center "Traefik v2"
                  _____                __ _ _            ____
                 |_   _| __ __ _  ___ / _(_) | __ __   _|___ \
                   | || '__/ _` |/ _ \ |_| | |/ / \ \ / / __) |
                   | || | | (_| |  __/  _| |   <   \ V / / __/
                   |_||_|  \__,_|\___|_| |_|_|\_\   \_/ |_____|
```

1. Kube deploy

```
vagrant up
```

wait a minutes


2. metallb

```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml

vi metallb-cm.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 172.42.42.240-172.42.42.250

kubeclt create -f metallb-cm.yaml

kubectl create deploy nginx --image nginx
kubectl expose deploy nginx --port 80 --type Loadbalancer
kubectl get svc
kubectl get all
kubectl delete pod nginx
```

3. Dynamic NFS provisioning



```
https://linuxize.com/post/how-to-install-and-configure-an-nfs-server-on-ubuntu-20-04/

# master
sudo apt install nfs-kernel-server
sudo cat /proc/fs/nfsd/versions

sudo mkdir -p /srv/nfs4/kubedata


vi /etc/exports
/srv/nfs4         172.42.42.0/24(rw,sync,no_subtree_check,crossmnt,fsid=0)
/srv/nfs4/kubedata 172.42.42.0/24(rw,sync,no_subtree_check)

sudo exportfs -ar
sudo exportfs -v

# firewall
sudo ufw allow from 192.168.33.0/24 to any port nfs
sudo ufw status

# clients
sudo apt update
sudo apt install nfs-common
sudo mkdir -p /kubedata
sudo mount -t nfs -o vers=4 172.42.42.100:/kubedata /kubedata
```

```
helm repo add nfs-subdir-external-provisioner \
  https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update
helm install nfs-provisioner \
  nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --set nfs.server=172.42.42.100 \
  --set nfs.path=/srv/nfs4/kubedata \
  --set storageClass.name=nfs-provisioner
  -n operations --create-namespace

kubectl apply -f yamls/pvc-nfs.yaml
kubectl get pvc
```

4. Traefik

```
helm version
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm search repo traefik
helm show values traefik/traefik > yamls/traefik-values.yaml
helm install traefik traefik/traefik --values yamls/traefik-values.yaml -n traefik --create-namespace
```

```
# desktop
kubectl -n traefik port-forward traefik-6b4dd86c7b-ln4dh 9000:9000

# from mac to desktop
ssh -L 9000:localhost:9000 gonza@192.168.0.3

# mac
open http://localhost:9000/dashboard
```

5. Deploy nginx demo

```
k create -f nginx-deploy-main.yaml -f nginx-deploy-blue.yaml -f nginx-deploy-green.yaml
k expose deploy nginx-deploy-main --port 80 --type LoadBalancer
k expose deploy nginx-deploy-blue --port 80 --type LoadBalancer
k expose deploy nginx-deploy-green --port 80 --type LoadBalancer
```

5. TLS

For disconnected environment use pebble to act like let's encrypt to interact with ACME protocol


```
❯ helm install pebble jupyterhub/pebble --values yamls/pebble-values.yaml -n traefik
NAME: pebble
LAST DEPLOYED: Tue Jun 21 21:44:46 2022
NAMESPACE: traefik
STATUS: deployed
REVISION: 1
NOTES:
The ACME server is available at:

    https://pebble.traefik/dir
    https://localhost:32443/dir

The ACME server generates leaf certificates to ACME clients,
and signs them with an insecure root cert, available at:

    https://pebble.traefik:8444/roots/0
    https://localhost:32444/roots/0

Communication with the ACME server itself requires
accepting a root certificate in configmap/pebble:

    kubectl get configmap/pebble -o jsonpath="{.data['root-cert\.pem']}"
❯ k get cm -n traefik
```

```
vi yamls/traefik-values.yaml
....
additionalArguments:
  - --certificatesresolvers.letsencrypt.acme.tlschallenge=true
  - --certificatesresolvers.letsencrypt.acme.email=test@hello.com
  - --certificatesresolvers.letsencrypt.acme.storage=/data/acme.json
  - --certificatesresolvers.letsencrypt.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory
```

6. Middleware

```
- 1-add-prefix.yaml

curl http://nginx.example.com > forward > http://nginx-service-main:80/hello

- 2-strip-prefix.yaml

curl http://nginx.example.com/blue > forward > http://nginx-service-blue:80/
curl http://nginx.example.com/green > forward > http://nginx-service-green:80/

- 3-redirect-scheme.yaml

curl http://nginx.example.com/ > forward > https://nginx.example.com/

- 4-basic-auth.yaml 

curl -u gonzalo:hello http://nginx.example.com
```

