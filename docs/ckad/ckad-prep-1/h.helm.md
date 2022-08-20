# Helm

- Add repo

```
helm repo add bitnami https://charts.bitnami.com/bitnami
```

- List

```
helm repo list
```

- Search chart

```
helm search hub prometheus
```

- Search repo

```
helm search repo prometheus
```

- Chart infromation

```
helm install prometheus bitnami/kube-prometheus
helm show chart prometheus/kube-prometheus
helm show values prometheus/kube-prometheus
```

- Dependencies

```
helm dependency update
helm install --dry-run prometheus bitnami/kube-prometheus
```

- Install 

```
helm install --repo http://charts.example.com myapp-instance myapp

helm install myapp-instance ./mychart

helm install -f ./my-extra-values.yml ./mychart

helm install --set key1=val1,key2=val2 myapp-instance ./mychart

helm install --set foo.bar=hello myapp-instance sourcerepo/myapp
```

- List

```
helm list
```

- Get objects renderized

```
helm get manifest myapp-instance

helm status myapp-instance
```

- Uninstall

```
helm uninstall myapp-instance
```


- Create a new job

```
helm craete myapp
```
