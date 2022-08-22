resource "yandex_container_registry" "gp-devops-registry" {
  name      = "gp-devops-registry"
  folder_id = local.folder_id
}