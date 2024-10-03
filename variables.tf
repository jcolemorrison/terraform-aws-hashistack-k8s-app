variable "project_name" {
  type        = string
  description = "The name of the project.  Used for naming resources."
  default     = "hashistack-k8s-app"
}

variable "aws_default_tags" {
  type        = map(string)
  description = "Default tags added to all AWS resources."
  default = {
    Project = "hashistack-k8s-app"
  }
}

variable "aws_default_region" {
  type        = string
  description = "The default region that all resources will be deployed into."
  default     = "us-east-1"
}

variable "eks_cluster_name" {
  type        = string
  description = "The name of the EKS cluster to add the app to."
}

variable "application_name" {
  type        = string
  description = "Name of the application.  Used for naming all k8s resources."
}

variable "default_container_image" {
  type        = string
  description = "Default service container image"
  default     = "nicholasjackson/fake-service:v0.26.0"
}