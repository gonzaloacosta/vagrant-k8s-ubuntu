# Podman

- Dockerfile

```
vim Dockerfile
FROM httpd:2.4
RUN echo "Hello World" > /usr/local/apache2/htdocs/index.html

podman build -t myhttpd . 
```

- Images

```bash
podman images
podman images tree myhttpd
```

- Run

```bash
# --port <container_port>:<host_port>
podman run --rm -d --name myhttpd --port 8080:80 myhttpd
podman logs -f myhttpd
curl http://localhost:80/
```

- Tags

```bash
# Docker registry http://registry:5000/
podman tag myhttpd registry:5000/myhttpd
podman push registry:5000/myhttpd
```

- Login external registry

```bash
podman login --username $REGISTRY_USERNAME --password $REGISTRY_PASSWORD docker.io
cat ${XDG_RUNTIME_DIR}/containers/auth.json
{
    "auths": {
        "docker.io": {
            "auth": "Z2l1bGl0JLSGtvbkxCcX1xb617251xh0x3zaUd4QW45Q3JuV3RDOTc="
        }
    }
}
```

- Create a secrets

```bash
k create secret generic my-docker-registry --from-file=.dockerconfigjson=${XDG_RUNTIME_DIR}/containers/auth.json --type=kubernetes.io/dockeconfigjson  
k create secret docker-registry my-docker-registry-server --docker-server=https://index.docker.io/v1/ --docker-username=$YOUR_USR --docker-password=$YOUR_PWD
```

- Assign secret to pod.

```bash
apiVersion: v1
kind: Pod
metadata:
  name: private-reg
spec:
  containers:
  - name: private-reg-container
    image: $YOUR_PRIVATE_IMAGE
  imagePullSecrets:
  - name: mysecret
```


