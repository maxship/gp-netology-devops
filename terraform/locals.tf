locals {
  cloud_id  = "b1g3me49qkcgicgvrgv2"
  folder_id = "b1ghgjk8qcckif39judt"
  zone      = "ru-central1-a"

  k8s = {
    region         = "ru-central1"
    version        = "1.19"
    node_platform  = "standard-v1"
    cp_platform    = "standard-v1"
    node_ssh_key   = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    instance_image = "fd8mfc6omiki5govl68h" # Ubuntu-20.04
  }
}