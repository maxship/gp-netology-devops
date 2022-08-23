# gp-devops-kubespray
DevOps Graduation Project (Netology): Terraform part.

## Этапы выполнения
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

Скачал репозиторий с Kubespray.

```shell script
$ git clone https://github.com/kubernetes-sigs/kubespray

# Установка зависимостей
$ sudo pip3 install -r requirements.txt

# Копирование примера в папку с нашей конфигурацией
$ cp -rfp inventory/sample inventory/gp-devops-k8s-cluster
```


При развертывании терраформом инфраструктуры на предыдущем этапе был получены файл
[hosts.yml](./inventory/gp-devops-k8s-cluster/hosts.yml). 

Запускаем плейбук.

```shell
$ ansible-playbook -i inventory/gp-devops-k8s-cluster/hosts.yml --become --become-user=root cluster.yml

```

Подключаемся к мастеру и копируем содержимое файла `/etc/kubernetes/admin`.

```shell
ssh ubuntu@84.201.134.49
sudo cat /etc/kubernetes/admin
NlU2K0lZdVlqd........ZJQ0FURS0tLS0tCg==
    server: https://127.0.0.1:6443
  name: cluster.local
contexts:
- context:
    cluster: cluster.local
    user: kubernetes-admin
  name: kubernetes-admin@cluster.local
current-context: kubernetes-admin@cluster.local
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: LS0tLS1CRU.......CBDRVJUSUZJQ0FURS0tLS0tCg==
    client-key-data: LS0tLS1CRU.........S0tLS0tCg==
```

Вставляем содержимое в локальный конфиг, и меняем `127.0.0.1` на внешний IP адрес мастера `84.201.134.49`.
```shell
code ~/.kube/config
```

Проверяем кластер.
```shell
kubectl get pods --all-namespaces
NAMESPACE     NAME                                    READY   STATUS    RESTARTS      AGE
kube-system   calico-node-5bj9w                       1/1     Running   0             42m
kube-system   calico-node-kx22r                       1/1     Running   0             42m
kube-system   calico-node-npvl9                       1/1     Running   0             42m
kube-system   calico-node-r8npj                       1/1     Running   0             42m
kube-system   coredns-74d6c5659f-7dtcv                1/1     Running   0             40m
kube-system   coredns-74d6c5659f-xv5cs                1/1     Running   0             39m
kube-system   dns-autoscaler-59b8867c86-gbmvn         1/1     Running   0             39m
kube-system   kube-apiserver-control-plane            1/1     Running   1             47m
kube-system   kube-controller-manager-control-plane   1/1     Running   2 (38m ago)   47m
kube-system   kube-proxy-44fpk                        1/1     Running   0             15m
kube-system   kube-proxy-574jb                        1/1     Running   0             15m
kube-system   kube-proxy-5hp8b                        1/1     Running   0             15m
kube-system   kube-proxy-qsxzt                        1/1     Running   0             15m
kube-system   kube-scheduler-control-plane            1/1     Running   2 (38m ago)   47m
kube-system   nginx-proxy-node-1                      1/1     Running   0             43m
kube-system   nginx-proxy-node-2                      1/1     Running   0             43m
kube-system   nginx-proxy-node-3                      1/1     Running   0             43m
kube-system   nodelocaldns-4g7dn                      1/1     Running   0             39m
kube-system   nodelocaldns-688bk                      1/1     Running   0             39m
kube-system   nodelocaldns-l925v                      1/1     Running   0             39m
kube-system   nodelocaldns-w5gzc                      1/1     Running   0             39m
```