/**
 * Copyright 2020 Google LLC
 * Modifications copyright 2022 Garden Germany GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  cluster_type           = "simple-autopilot-public"
  network_name           = "simple-autopilot-public-network"
  subnet_name            = "simple-autopilot-public-subnet"
  master_auth_subnetwork = "simple-autopilot-public-master-subnet"
  pods_range_name        = "ip-range-pods-simple-autopilot-public"
  svc_range_name         = "ip-range-svc-simple-autopilot-public"
  subnet_names           = [for subnet_self_link in module.gcp-network.subnets_self_links : split("/", subnet_self_link)[length(split("/", subnet_self_link)) - 1]]
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/beta-autopilot-public-cluster"
  project_id                      = var.project_id
  name                            = "${local.cluster_type}-cluster"
  regional                        = true
  region                          = var.region
  network                         = module.gcp-network.network_name
  subnetwork                      = local.subnet_names[index(module.gcp-network.subnets_names, local.subnet_name)]
  ip_range_pods                   = local.pods_range_name
  ip_range_services               = local.svc_range_name
  release_channel                 = "RAPID"
  enable_vertical_pod_autoscaling = true
  issue_client_certificate        = true
  datapath_provider               = "ADVANCED_DATAPATH"
}


data "google_container_cluster" "gke_cluster" {
  name     = module.gke.name
  location = module.gke.location

  # Make sure that we always use the same value for this that the module does, because the module doesn't export this as an output
  project = var.project_id
}

data "template_file" "kubeconfig" {
  template = file("${path.module}/kubeconfig-template.yaml")

  vars = {
    cluster_name    = module.gke.name
    endpoint        = module.gke.endpoint
    cluster_ca      = module.gke.ca_certificate
    client_cert     = data.google_container_cluster.gke_cluster.master_auth.0.client_certificate
    client_cert_key = data.google_container_cluster.gke_cluster.master_auth.0.client_key
  }
}

resource "local_file" "kubeconfig" {
  filename = "${path.module}/kubeconfig.yaml"
  content  = data.template_file.kubeconfig.rendered
}

# authorize client-admin for operations on K8s cluster
resource "kubernetes_cluster_role_binding" "client_admin" {
  metadata {
    name = "client-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "User"
    name      = "client"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "kube-system"
  }
  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }
}

# module "gke_auth" {
#   source = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/auth"

#   project_id   = var.project_id
#   location     = module.gke.location
#   cluster_name = module.gke.name
# }

# resource "local_file" "kubeconfig" {
#   filename = "${path.module}/kubeconfig.yaml"
#   content  = module.gke_auth.kubeconfig_raw
# }
