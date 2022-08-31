### Создание Kubernetes кластера

Скачиваем репозиторий с Kubespray.

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
ssh ubuntu@51.250.79.113
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

Вставляем содержимое в локальный конфиг, и меняем `127.0.0.1` на внешний IP адрес мастера `62.84.119.101`.

```shell
code ~/.kube/config
```

Проверяем кластер.
```shell
kubectl get nodes
NAME            STATUS   ROLES           AGE   VERSION
control-plane   Ready    control-plane   17m   v1.24.4
node-1          Ready    <none>          13m   v1.24.4
node-2          Ready    <none>          13m   v1.24.4
node-3          Ready    <none>          13m   v1.24.4

kubectl get pods --all-namespaces
NAMESPACE     NAME                                    READY   STATUS    RESTARTS        AGE
kube-system   calico-node-8zqb5                       1/1     Running   0               13m
kube-system   calico-node-dtpt2                       1/1     Running   0               13m
kube-system   calico-node-rdxvp                       1/1     Running   0               13m
kube-system   calico-node-tcl8j                       1/1     Running   0               13m
kube-system   coredns-74d6c5659f-4pqq2                1/1     Running   0               10m
kube-system   coredns-74d6c5659f-8xcz9                1/1     Running   0               10m
kube-system   dns-autoscaler-59b8867c86-hbm8m         1/1     Running   0               10m
kube-system   kube-apiserver-control-plane            1/1     Running   1               18m
kube-system   kube-controller-manager-control-plane   1/1     Running   3 (8m38s ago)   18m
kube-system   kube-proxy-2r2k2                        1/1     Running   0               15m
kube-system   kube-proxy-hzbdq                        1/1     Running   0               15m
kube-system   kube-proxy-mdxl8                        1/1     Running   0               15m
kube-system   kube-proxy-tdwc9                        1/1     Running   0               15m
kube-system   kube-scheduler-control-plane            1/1     Running   2 (8m38s ago)   18m
kube-system   nginx-proxy-node-1                      1/1     Running   0               14m
kube-system   nginx-proxy-node-2                      1/1     Running   0               14m
kube-system   nginx-proxy-node-3                      1/1     Running   0               14m
kube-system   nodelocaldns-2kfxs                      1/1     Running   0               10m
kube-system   nodelocaldns-9w77v                      1/1     Running   0               10m
kube-system   nodelocaldns-v84sw                      1/1     Running   0               10m
kube-system   nodelocaldns-xxngq                      1/1     Running   0               10m
```