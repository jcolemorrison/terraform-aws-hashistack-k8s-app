locals {
  eks_cluster_name = "hashistack-${var.hashistack_sandbox_name}-infra"
  project_name     = "hashistack-${var.hashistack_sandbox_name}-k8s-app"
  aws_default_tags = {
    Project = "hashistack-${var.hashistack_sandbox_name}-k8s-app"
  }
}