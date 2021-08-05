variable "folder" { description = "The folder name of the parent folder." }
variable "org_id" { description = "THe organisation ID for the parent org." }
variable "billing_account" { description = "The billing account to bind to the project." }
variable "env_name" { description = "The name of the environment." }
variable "service_account" { description = "The pf service account used to run gcloud commands." }
variable "apis" {
  description = "A list of APIs to enable for the project."
  type        = list(string)
}
variable "prefix" {}