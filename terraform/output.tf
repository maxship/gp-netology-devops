output "external_ip_control_plane" {
  value = yandex_compute_instance.k8s-control-plane.network_interface.0.nat_ip_address
}

output "external_ip_nodes" {
  value = yandex_compute_instance_group.k8s-nodes-group.instances[*].network_interface[0].nat_ip_address
}

# Export host.yml into ../../kubespray/inventory/gp-devops-k8s-cluster/
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
        supplementary_addresses_in_ssl_keys: ${yandex_compute_instance.k8s-control-plane.network_interface.0.nat_ip_address}
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
    DOC
  filename = "../../kubespray/inventory/gp-devops-k8s-cluster/hosts.yml"
}

## Export k8s-cluster.yml into kubespray/inventory/gp-devops-k8s-cluster/group_vars/k8s_cluster/
#resource "local_file" "k8s_vars" {
#  content  = <<-DOC
#---
#kube_config_dir: /etc/kubernetes
#kube_script_dir: "{{ bin_dir }}/kubernetes-scripts"
#kube_manifest_dir: "{{ kube_config_dir }}/manifests"
#kube_cert_dir: "{{ kube_config_dir }}/ssl"
#kube_token_dir: "{{ kube_config_dir }}/tokens"
#kube_api_anonymous_auth: true
#kube_version: v1.23.5
#local_release_dir: "/tmp/releases"
#retry_stagger: 5
#kube_cert_group: kube-cert
#kube_log_level: 2
#credentials_dir: "{{ inventory_dir }}/credentials"
#kube_network_plugin: calico
#kube_network_plugin_multus: false
#kube_service_addresses: 10.233.0.0/18
#kube_pods_subnet: 10.233.64.0/18
#kube_network_node_prefix: 24
#enable_dual_stack_networks: false
#kube_service_addresses_ipv6: fd85:ee78:d8a6:8607::1000/116
#kube_pods_subnet_ipv6: fd85:ee78:d8a6:8607::1:0000/112
#kube_network_node_prefix_ipv6: 120
#kube_apiserver_ip: "{{ kube_service_addresses|ipaddr('net')|ipaddr(1)|ipaddr('address') }}"
#kube_apiserver_port: 6443  # (https)
#kube_apiserver_insecure_port: 0  # (disabled)
#kube_proxy_mode: ipvs
#kube_proxy_strict_arp: false
#kube_proxy_nodeport_addresses: >-
#  {%- if kube_proxy_nodeport_addresses_cidr is defined -%}
#  [{{ kube_proxy_nodeport_addresses_cidr }}]
#  {%- else -%}
#  []
#  {%- endif -%}
#kube_encrypt_secret_data: false
#cluster_name: cluster.local
#ndots: 2
#dns_mode: coredns
#enable_nodelocaldns: true
#enable_nodelocaldns_secondary: false
#nodelocaldns_ip: 169.254.25.10
#nodelocaldns_health_port: 9254
#nodelocaldns_second_health_port: 9256
#nodelocaldns_bind_metrics_host_ip: false
#nodelocaldns_secondary_skew_seconds: 5
#enable_coredns_k8s_external: false
#coredns_k8s_external_zone: k8s_external.local
#enable_coredns_k8s_endpoint_pod_names: false
#resolvconf_mode: host_resolvconf
#deploy_netchecker: false
#skydns_server: "{{ kube_service_addresses|ipaddr('net')|ipaddr(3)|ipaddr('address') }}"
#skydns_server_secondary: "{{ kube_service_addresses|ipaddr('net')|ipaddr(4)|ipaddr('address') }}"
#dns_domain: "{{ cluster_name }}"
#container_manager: containerd
#kata_containers_enabled: false
#kubeadm_certificate_key: "{{ lookup('password', credentials_dir + '/kubeadm_certificate_key.creds length=64 chars=hexdigits') | lower }}"
#k8s_image_pull_policy: IfNotPresent
#kubernetes_audit: false
#dynamic_kubelet_configuration: false
#default_kubelet_config_dir: "{{ kube_config_dir }}/dynamic_kubelet_dir"
#dynamic_kubelet_configuration_dir: "{{ kubelet_config_dir | default(default_kubelet_config_dir) }}"
#podsecuritypolicy_enabled: false
#supplementary_addresses_in_ssl_keys: [${yandex_compute_instance.k8s-control-plane.network_interface.0.nat_ip_address}]
#volume_cross_zone_attachment: false
#persistent_volumes_enabled: false
#event_ttl_duration: "1h0m0s"
#auto_renew_certificates: false
#    DOC
#  filename = "../gp-devops-k8s/kubespray/inventory/gp-devops-k8s-cluster/group_vars/k8s_cluster/k8s-cluster.yml"
#}