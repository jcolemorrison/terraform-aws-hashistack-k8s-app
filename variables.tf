variable "aws_default_region" {
  type        = string
  description = "The default region that all resources will be deployed into."
  default     = "us-east-1"
}

variable "hashistack_sandbox_name" {
  type        = string
  description = "The name of the HashiStack sandbox.  i.e. game, store, social"
}

variable "application_name" {
  type        = string
  description = "Name of the application.  Used for naming all k8s resources."
}

variable "application_entrypoint" {
  type        = string
  description = "Application entrypoint"
  # default     = "/app/fake-service"
}

variable "container_image" {
  type        = string
  description = "Service container image"
  # default     = "nicholasjackson/fake-service:v0.26.0"
}