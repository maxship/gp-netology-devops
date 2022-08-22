locals {
  cloud_id = "b1g3me49qkcgicgvrgv2"
  folder_id = "b1ghgjk8qcckif39judt"

  k8s = {
    region  = "ru-central1"
    version = "1.19"
    node_platform = "standard-v1"
    node_ssh_key = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  zones = {
    a = {
      zone = "ru-central1-a"
      cidr = ["192.168.10.0/24"]
    }
    b = {
      zone = "ru-central1-b"
      cidr = ["192.168.20.0/24"]
    }
    c = {
      zone = "ru-central1-c"
      cidr = ["192.168.30.0/24"]
    }
  }
}