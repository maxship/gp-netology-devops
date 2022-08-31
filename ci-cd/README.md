## Установка и настройка CI/CD

Для создания пайплайна для сборки и деплоя приложения выбран Gitlab CI/CD.

В репозиторий с ранее созданным приложением был добавлен helm chart.  
Ссылка на репозиторий: [gitlab.com/maxship/my-k8s-app](https://gitlab.com/maxship/my-k8s-app)


### Установка агента Gitlab в Кубернетес

Для взаимодействия Gitlab CI/CD с кластером Kubernetes установим в него [gitlab агент](https://docs.gitlab.com/ee/user/clusters/agent/ci_cd_workflow.html).

Создадим файл конфига `.gitlab/agents/gitlab-agent/config.yaml`, в котором пропишем путь к проекту, к которому должен быть открыт доступ агенту.

```yaml
ci_access:
  projects:
    - id: maxship/my-k8s-app
```

Устанавливаем агент в кластер с помощью helm:

```
 helm upgrade --install gitlab-agent gitlab/gitlab-agent \
>     --namespace gitlab-agent \
>     --create-namespace \
>     --set image.tag=v15.4.0 \
>     --set config.token=kEiXz_CBdzmzrKtyx.....jVAVudkPw \
>     --set config.kasAddress=wss://kas.gitlab.com

```

В файле [`.gitlab-ci.yml`](https://gitlab.com/maxship/my-k8s-app/-/blob/master/.gitlab-ci.yml) настроен пайплайн для автоматической сборки и деплоя приложения.

При любом коммите создается новый докер образ и загружается в репозиторий gitlab. При создании нового тега создается образ, и из него с помошью helm деплоится новая версия приложения.

Ссылки на результаты успешных джоб: 

- [сборка по коммиту ](https://gitlab.com/maxship/my-k8s-app/-/jobs/2960186767)
- [сборка по тегу](https://gitlab.com/maxship/my-k8s-app/-/jobs/2960191452)
- [деплой из образа с тегом](https://gitlab.com/maxship/my-k8s-app/-/jobs/2960191455)

![repo](./img/repo.png)

![jobs](./img/jobs.png)

![job1](./img/job-build.png)

![job2](./img/job-deploy.png)

Проверяем обновленный деплоймент и удостоверяемся, что он создан из образа с только что добавленным тегом:

```shell
kubectl describe deployments.apps my-k8s-app --namespace gitlab-agent 
Name:                   my-k8s-app
Namespace:              gitlab-agent
CreationTimestamp:      Wed, 31 Aug 2022 12:22:19 +0600
Labels:                 app.kubernetes.io/managed-by=Helm
Annotations:            deployment.kubernetes.io/revision: 4
                        meta.helm.sh/release-name: my-k8s-app
                        meta.helm.sh/release-namespace: default
Selector:               app=my-k8s-app
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=my-k8s-app
  Containers:
   my-k8s-app:
    Image:        registry.gitlab.com/maxship/my-k8s-app:v1.0.0
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   my-k8s-app-77c579f5b4 (3/3 replicas created)
```