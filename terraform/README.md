# gp-devops-terraform
DevOps Graduation Project (Netology): Terraform part.

## Этапы выполнения

### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
- Следует использовать последнюю стабильную версию [Terraform](https://www.terraform.io/).

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/)  
   б. Альтернативный вариант: S3 bucket в созданном ЯО аккаунте
3. Настройте [workspaces](https://www.terraform.io/docs/language/state/workspaces.html)  
   а. Рекомендуемый вариант: создайте два workspace: *stage* и *prod*. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.  
   б. Альтернативный вариант: используйте один workspace, назвав его *stage*. Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (*default*).
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать региональный мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

---

## Решение

### Создание облачной инфраструктуры. Создание Kubernetes кластера

В связи с тем, что во время выполнения задания, придется многократно запускать/останавливать кластер Кубернетеса (для экономии денег в облаке), для ускорения этого процесса было принято решение всю инфраструктуру сделать в Терраформе, использовав решение `Managed Service for Kubernetes` в Yandex Cloud. Поэтому задачи создания инфраструктуры в Терраформе и развертывания кластера Кубернетеса объединены в один блок.

В качестве бекенда для Терраформа выбран Terraform Cloud.
В Terraform Cloud создан workspace `gp-devops-terraform-stage`. Тип подключения - VCS (репозиторий Github). В переменные окружения прописан токен авторизации `YC_TOKEN`.

Для подключения к облаку в `main.tf` внесен соответствующий блок.
```terraform
# main.tf
terraform 
{
// Подключение к Terraform Cloud для удаленного хранения стейтов  
  cloud {
    organization = "maxship"
    workspaces {
      name = "gp-devops-terraform-stage"
    }
  }

  required_version = ">= 1.2.7"

  required_providers {
      yandex = {
        source  = "yandex-cloud/yandex"
        version = "0.77.0"
      }
  }
}
```

```shell
# Логинимся TC, создаем API токен
$ terraform login
Terraform will request an API token for app.terraform.io using your browser.

# Инициализируем Terraform cloud
$ terraform init
Terraform Cloud has been successfully initialized!

# Проверяем работоспособность бэкенда
$ terraform plan
Running plan in Terraform Cloud. Output will stream here.
....
Terraform has compared your real infrastructure against your configuration
and found no differences, so no changes are needed.
```
Теперь на локальной машине можно выполнить только `terraform plan` , а запустить`terraform apply` только из веб-интерфейса. `terraform plan` запускается автоматически при изменении файлов `.tf` в отслеживаемом репозитории. Стейты полученной инфраструктуры хранятся в Terraform Cloud.

![tfcloud-autoplan](img/tfcloud-autoplan.png)

![tfcloud-apply](img/tfcloud-apply.png)

![tfcloud-runs](img/tfcloud-runs.png)

После применения конфигурации получаем kubectl конфиг кластера с помощью клиента YC.
```shell
$ yc managed-kubernetes --folder-name gp-devops cluster get-credentials k8s-cluster --external
```

Проверяем файл `~/.kube/config`

```yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CR.......0tCg==
    server: https://51.250.74.59
  name: yc-managed-k8s-cat76u2lj2p2qek5h6np
contexts:
- context:
    cluster: yc-managed-k8s-cat76u2lj2p2qek5h6np
    user: yc-managed-k8s-cat76u2lj2p2qek5h6np
  name: yc-k8s-cluster
current-context: yc-k8s-cluster
kind: Config
preferences: {}
users:
- name: yc-managed-k8s-cat76u2lj2p2qek5h6np
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - k8s
      - create-token
      - --profile=default
      command: /home/maxship/yandex-cloud/bin/yc
      env: null
      provideClusterInfo: false
```