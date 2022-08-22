// VPC network
resource "yandex_vpc_network" "vpc-stage" {
  name = "vpc-stage"
}

// Public subnets
resource "yandex_vpc_subnet" "public-subnet-a" {
  name           = "public-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc-stage.id
}
resource "yandex_vpc_subnet" "public-subnet-b" {
  name           = "public-b"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.vpc-stage.id
}
resource "yandex_vpc_subnet" "public-subnet-c" {
  name           = "public-c"
  v4_cidr_blocks = ["192.168.30.0/24"]
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.vpc-stage.id
}