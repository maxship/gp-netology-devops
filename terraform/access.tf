// Create SA
resource "yandex_iam_service_account" "k8s-sa" {
  folder_id = local.folder_id
  name      = "terraform-service-account"
}

// Grant permissions
resource "yandex_resourcemanager_folder_iam_binding" "k8s-editor" {
  folder_id = local.folder_id
  role      = "editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  ]
  depends_on = [
    yandex_iam_service_account.k8s-sa
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = local.folder_id
  role      = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
  ]
  depends_on = [
    yandex_iam_service_account.k8s-sa
  ]

}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-access-key" {
  service_account_id = yandex_iam_service_account.k8s-sa.id
  description        = "static access key for object storage"
  depends_on         = [yandex_iam_service_account.k8s-sa]
}

// Use keys to create bucket
resource "yandex_storage_bucket" "gp-devops-s3-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-access-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-access-key.secret_key
  depends_on = [yandex_iam_service_account_static_access_key.sa-static-access-key]
  bucket     = "gp-devops-s3-bucket"
  // Включаем шифрование на стороне сервера по умолчанию
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.sym-key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

// Создаем ключ шифрования
resource "yandex_kms_symmetric_key" "sym-key" {
  folder_id         = local.folder_id
  name              = "Ключ для шифрования"
  description       = "Symmetric-Key"
  default_algorithm = "AES_256"
  rotation_period   = "168h"
}

