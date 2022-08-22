// k8s cluster
resource "yandex_kubernetes_cluster" "k8s-cluster" {
  folder_id = local.folder_id
  name                    = "k8s-cluster"
  description             = "kubernetes cluster"
  release_channel         = "STABLE"
  network_policy_provider = "CALICO"

  network_id = yandex_vpc_network.vpc-stage.id

#  kms_provider {
#    key_id = yandex_kms_symmetric_key.sym-key.id // ключ шифрования
#  }

  master {
    version   = local.k8s.version
    public_ip = true

    regional {
      region = local.k8s.region

      dynamic "location" {
        for_each = local.zones
        content {
          zone      = yandex_vpc_subnet.public-subnet[location.key].zone
          subnet_id = yandex_vpc_subnet.public-subnet[location.key].id
        }
      }
    }

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        day        = "monday"
        start_time = "15:00"
        duration   = "3h"
      }
    }
  }

  service_account_id = yandex_iam_service_account.k8s-sa.id

  node_service_account_id = yandex_iam_service_account.k8s-sa.id

  depends_on = [
    yandex_resourcemanager_folder_iam_binding.k8s-editor,
    yandex_resourcemanager_folder_iam_binding.images-puller,
    yandex_iam_service_account.k8s-sa
  ]
}

// k8s node group
resource "yandex_kubernetes_node_group" "k8s-node-group" {
  for_each    = local.zones
  cluster_id  = yandex_kubernetes_cluster.k8s-cluster.id
  name        = "k8s-node-roup"
  description = "kubernetes node group"
  version     = local.k8s.version

  instance_template {
    platform_id = local.k8s.node_platform

# Access to node via ssh
    metadata = {
      ssh-keys = local.k8s.node_ssh_key
    }

    network_interface {
      nat = true
      subnet_ids = [
        "${yandex_vpc_subnet.public-subnet[each.key].id}"
      ]
    }

    resources {
      memory = 2
      cores  = 2
      core_fraction = 20
    }

    boot_disk {
      type = "network-hdd"
      size = 32
    }

    scheduling_policy {
      preemptible = true
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    auto_scale {
      initial = 1
      max     = 2
      min     = 1
    }
  }

  allocation_policy {
    location {
      zone = each.value.zone
    }
  }
}