terraform {

#  cloud {
#    organization = "maxship"
#    workspaces {
#      name = "gp-devops-terraform-stage"
#    }
#  }

  required_version = ">= 1.2.7"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.77.0"
    }
  }
}

provider "yandex" {
  cloud_id = local.cloud_id
  folder_id = local.folder_id
}


