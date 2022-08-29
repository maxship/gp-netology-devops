connect to cluster

access token
_cmq6PusxSNjkqCburXzfyQXfDQikbzKUwHKNMvyFdBvS3CbjA

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
