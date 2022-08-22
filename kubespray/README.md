# Установка и настройка кластера Kubernetes.

Для установки кластера воспользовался репозиторием [Kubespray](https://github.com/kubernetes-sigs/kubespray). Последняя версия из ветки `main` у меня установилась с ошибками, файл `/etc/kubernetes/admin.conf` не был создан. Поэтому был загружена версия [release-2.18](https://github.com/kubernetes-sigs/kubespray/tree/release-2.18).

```Shell
git clone https://github.com/kubernetes-sigs/kubespray -b 
````
Установка зависимостей

```Shell
sudo pip3 install -r requirements.txt
````
Копирование примера в папку с вашей конфигурацией

```Shell
cp -rfp inventory/sample inventory/gp-devops-k8s-cluster
```

После создания директории с инвентарем, применяем [конфигурацию терраформа](../terraform). В результате выполнения создатся файл [host.yml](./inventory/gp-devops-k8s-cluster/hosts.yml).
Запускаем установку кубернетеса.

```Shell
ansible-playbook -i inventory/gp-devops-k8s-cluster/hosts.yml --become --become-user=root cluster.yml
```