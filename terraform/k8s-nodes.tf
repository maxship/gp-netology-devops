resource "yandex_compute_instance_group" "k8s-node-group" {
  name               = "k8s-node-group"
  folder_id          = local.folder_id
  service_account_id = yandex_iam_service_account.k8s-sa.id

  instance_template {

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = local.k8s.instance_image
        size     = 100
      }
    }

    scheduling_policy {
      preemptible = true # Прерываемая
    }

    network_interface {
      subnet_ids = [
        yandex_vpc_subnet.public-subnet-a.id,
        yandex_vpc_subnet.public-subnet-b.id,
        yandex_vpc_subnet.public-subnet-c.id,
      ]
      nat = true
    }

    metadata = {
      ssh-keys = local.k8s.node_ssh_key
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [
      "ru-central1-a",
      "ru-central1-b",
      "ru-central1-c"
    ]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }
}