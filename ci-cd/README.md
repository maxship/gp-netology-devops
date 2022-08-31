Развертывание приложения

```shell
helm uninstall my-k8s-app ./my-k8s-app

```


connect to cluster whith agent

```shell
helm repo add gitlab https://charts.gitlab.io
helm repo update
helm upgrade --install k8s-agent gitlab/gitlab-agent \
    --namespace gitlab-agent \
    --create-namespace \
    --set image.tag=v15.4.0 \
    --set config.token=_cmq6PusxSNjkqCburXzfyQXfDQikbzKUwHKNMvyFdBvS3CbjA \
    --set config.kasAddress=wss://kas.gitlab.com
```

https://chris-vermeulen.com/using-gitlab-registry-with-kubernetes/

```shell
echo -n "gitlab+deploy-token-1301711:gVh...Va45XdY" | base64
```
.dockerconfigjson
```json
{
    "auths": {
        "https://registry.gitlab.com":{
            "username":"gitlab+deploy-token-1301711",
            "password":"gV......dY",
            "email":"m.o.shipitsyn@mail.ru",
            "auth":"Z2l0bG.......Q1WGRZ"
    	}
    }
}
```