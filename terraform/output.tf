output "external_ip_control_plane" {
  value = yandex_compute_instance.k8s-control-plane.network_interface.0.nat_ip_address
}

output "external_ip_nodes" {
  value = yandex_compute_instance_group.k8s-nodes-group.instances[*].network_interface[0].nat_ip_address
}

# Export host.yml into /kubespray/inventory/gp-devops-k8s-cluster/
resource "local_file" "k8s_hosts_ip" {
  content  = <<-DOC
---
all:
  hosts:
    control-plane:
      ansible_host: ${yandex_compute_instance.k8s-control-plane.network_interface.0.nat_ip_address}
      ansible_user: ubuntu
    node-1:
      ansible_host: ${yandex_compute_instance_group.k8s-nodes-group.instances[0].network_interface.0.nat_ip_address}
      ansible_user: ubuntu
    node-2:
      ansible_host: ${yandex_compute_instance_group.k8s-nodes-group.instances[1].network_interface.0.nat_ip_address}
      ansible_user: ubuntu
    node-3:
      ansible_host: ${yandex_compute_instance_group.k8s-nodes-group.instances[2].network_interface.0.nat_ip_address}
      ansible_user: ubuntu
  children:
    kube_control_plane:
      hosts:
        control-plane:
    kube_node:
      hosts:
        node-1:
        node-2:
        node-3:
    etcd:
      hosts:
        control-plane:
    k8s_cluster:
      vars:
        supplementary_addresses_in_ssl_keys: [${yandex_compute_instance.k8s-control-plane.network_interface.0.nat_ip_address}]
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
    DOC
  filename = "../../kubespray/inventory/gp-devops-k8s-cluster/hosts.yml"
}