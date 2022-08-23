resource "yandex_lb_target_group" "nlb-group-grafana" {

  name       = "nlb-group-grafana"
  depends_on = [yandex_compute_instance_group.k8s-node-group]

  dynamic "target" {
    for_each = yandex_compute_instance_group.k8s-node-group.instances
    content {
      subnet_id = target.value.network_interface.0.subnet_id
      address   = target.value.network_interface.0.ip_address
    }
  }
}

resource "yandex_lb_network_load_balancer" "nlb-graf" {

  name = "nlb-graf"

  listener {
    name        = "grafana-listener"
    port        = 3000
    target_port = 30902
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.nlb-group-grafana.id

    healthcheck {
      name = "healthcheck"
      tcp_options {
        port = 30902
      }
    }
  }
  depends_on = [yandex_lb_target_group.nlb-group-grafana]
}

#resource "yandex_lb_network_load_balancer" "nlb-nginx" {
#
#  name = "nlb-nginx"
#
#  listener {
#    name        = "app-listener"
#    port        = 80
#    target_port = 30080
#    external_address_spec {
#      ip_version = "ipv4"
#    }
#  }
#
#  attached_target_group {
#    target_group_id = yandex_lb_target_group.nlb-group-grafana.id
#
#    healthcheck {
#      name = "healthcheck"
#      tcp_options {
#        port = 30080
#      }
#    }
#  }
#  depends_on = [yandex_lb_target_group.nlb-group-grafana]
#}
