resource "yandex_compute_instance" "k8s-control-plane" {

  name                      = "control-plane"
  platform_id               = local.k8s.cp_platform
  allow_stopping_for_update = true
  zone                      = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true # Прерываемая
  }

  boot_disk {
    initialize_params {
      image_id = local.k8s.instance_image
      size     = 100
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet-a.id
    nat       = true
  }

  metadata = {
    ssh-keys = local.k8s.node_ssh_key
  }
}