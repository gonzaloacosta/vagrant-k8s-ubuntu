# loki install

```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm show values grafana/loki-stack > loki-stack-values.yaml

cat << EOF >> loki-stack-values.yaml
loki:
  enabled: true
  persistence:
    enable: true
    storageClassName: nfs-provisioner
    size: 1Gi

promtail:
  enabled: true

grafana:
  enabled: true
  sidecar:
    datasources:
      enabled: true
      maxLines: 1000
  image:
    tag: 8.3.5
EOF

helm install loki-stack grafana/loki-stack --values loki-stack-values.yaml -n loki --create-namespace
helm list -n loki


k -n loki port-forward svc/loki-stack-grafana 3000:80
ssh -L 3000:localhost:3000 gonza@192.168.0.3
open http://localhost:3000

k get secrets -o yaml loki-stack-grafana -n loki

https://grafana.com/docs/loki/latest/installation/microservices-helm/

# uninstall
helm uninstall -n loki grafana/loki-stack

```
