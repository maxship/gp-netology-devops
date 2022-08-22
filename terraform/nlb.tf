#resource "yandex_lb_target_group" "nlb-group-grafana" {
#
#  name       = "nlb-group-grafana"
#  depends_on = [yandex_compute_instance_group.k8s-nodes-group]
#
#  dynamic "target" {
#    for_each = yandex_compute_instance_group.k8s-nodes-group.instances
#    content {
#      subnet_id = target.value.network_interface.0.subnet_id
#      address   = target.value.network_interface.0.ip_address
#    }
#  }
#}
#
#resource "yandex_lb_network_load_balancer" "nlb-grafana" {
#
#  name = "nlb-grafana"
#
#  listener {
#    name        = "grafana-listener"
#    port        = 3000
#    target_port = 3000
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
#        port = 3000
#      }
#    }
#  }
#  depends_on = [yandex_lb_target_group.nlb-group-grafana]
#}
#
#resource "yandex_lb_network_load_balancer" "test-app-balancer" {
#  name = "nlb-app"
#
#  listener {
#    name        = "app-listener"
#    port        = 80
#    target_port = 8080
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
#        port = 8080
#      }
#    }
#  }
#  depends_on = [
#    yandex_lb_target_group.nlb-group-grafana,
#    yandex_lb_network_load_balancer.nlb-grafana
#  ]
#}


## loadbalancer
#resource "yandex_lb_network_load_balancer" "nlb" {
#    name = "nlb-app"
#    listener {
#        name = "app-listener"
#        port = 80
#        target_port = 30003
#        external_address_spec {
#            ip_version = "ipv4"
#        }
#    }
#    listener {
#        name = "grafana-listener"
#        port = 8080
#        target_port = 30902
#        external_address_spec {
#            ip_version = "ipv4"
#        }
#    }
#    attached_target_group {
#        target_group_id = "${yandex_lb_target_group.tg-1.id}"
#        healthcheck {
#            name = "http"
#            http_options {
#                port = 30003
#            }
#        }
#    }
#}