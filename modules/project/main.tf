# -------------------------------- MODULES ----------------------------------------------------#

# This includes the attributes needed to create the project. There are some required variables and they
# can be found in the documentation for the module. 

module "project" {
  source            = "git@github.com:cts-terraform-modules/terraform-google-project-factory.git//modules/core_project_factory?ref=v11.0.0" # Updated to the latest
  name              = "${var.prefix}-${var.env_name}"
  random_project_id = true
  folder_id         = var.folder
  org_id            = var.org_id
  billing_account   = var.billing_account

  activate_apis               = var.apis
  disable_services_on_destroy = false
  disable_dependent_services  = false

  enable_shared_vpc_service_project = false
}

# -------------------------------- OUTPUT ----------------------------------------------------#

# This output block will output everything within the project module above. This contains a lot
# of information. It holds everything within the project module and means that all of this 
# information can then be accessed in other terragrunt.hcl configs. 

# The following attributes are included within the project module:
#     source
#     name
#     random_project_id
#     folder_id
#     org_id
#     billing_account
#     activate_apis
#     disable_services_on_destroy
#     disable_dependent_services
#     enable_shared_vpc_service_project

# There are a lot of optional attributes that can be included to customise the creation of the project.
# If these are included then they are also included in the output

# Others are also included and need to be sought out. These can be found in the outputs.tf 
# file for the module (https://github.com/cts-terraform-modules/terraform-google-project-factory/blob/master/modules/core_project_factory/outputs.tf)

# These include:
#     project_name
#     project_id
#     project_number
#     service_account_id
#     service_account_display_name
#     service_account_email
#     service_account_name
#     service_account_unique_id
#     project_bucket_name
#     project_bucket_self_link
#     project_bucket_url
#     api_s_account
#     api_s_account_fmt
#     enabled_apis
#     enabled_api_identities


# This means that all of those attributes can be accessed wherever there is a dependency block that
# points to this project module (found within terragrunt.hcl files).

output "project" { value = module.project }
