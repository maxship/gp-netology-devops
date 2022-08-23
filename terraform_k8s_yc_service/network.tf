// VPC network
resource "yandex_vpc_network" "vpc-stage" {
  name = "vpc-stage"
}

// public subnets
resource "yandex_vpc_subnet" "public-subnet" {
  for_each       = local.zones
  zone           = each.value.zone
  network_id     = yandex_vpc_network.vpc-stage.id
  v4_cidr_blocks = each.value.cidr
}