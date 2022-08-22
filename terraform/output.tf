output "k8s_external_ip" {
  value = "${yandex_kubernetes_cluster.k8s-cluster.master[0].external_v4_endpoint}"
}

# Для подключения к кластеру с помощью kubectl
output "k8s_cluster_kubectl_init_local" {
  value = "To access k8s cluster from local host via YC client, enter this command: 'yc managed-kubernetes --folder-name gp-devops cluster get-credentials ${yandex_kubernetes_cluster.k8s-cluster.name} --external'"
}
