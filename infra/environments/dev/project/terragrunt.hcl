# -------------------------------- INPUTS ----------------------------------------------------#

# When looking through the documentation for the project module (found here at https://github.com/cts-terraform-modules/terraform-google-project-factory)
# you can see that there a number of required inputs:
#     billing_account
#     name
#     org_id

# However, these are not found within the inputs block below. That's because they have already been
# defined in the root level terragrunt.hcl inputs block

inputs = {
  apis = [
    "compute.googleapis.com"
  ]
}

# -------------------------------- LOCALS ----------------------------------------------------#

# The only reason that the root_vars and the vars variables are needed here is because
# they are being used outside of the inputs block (i.e. in the terraform block).

# If they were being declared here and used within the inputs block then that would be a waste,
# since those values are already being declared at the root level

locals {
  default_yaml_path = find_in_parent_folders("empty.yaml") # (Empty yaml i. ../empty.yaml)
  root_vars         = yamldecode(file(find_in_parent_folders("root.yaml", local.default_yaml_path))) # (Variables defined in Mukluk yaml)
  vars              = yamldecode(file(find_in_parent_folders("env.yaml", local.default_yaml_path))) # (Version stated in ../env.yaml)
  version           = local.vars.version # (Version stated in ../env.yaml)
  repo_owner        = local.root_vars.repo_owner #(cts)
}

# -------------------------------- TERRAFORM ----------------------------------------------------#

# The terraform block here is defining where to grab the module from. In this instance
# it is grabbing it from github and the version is the git tag that has been assigned to it

# Using git tag means that you can have multiple versions of the modules and they can all be easily referenced.
# One big advantage for this is that if there are updates to terraform or terragrunt or how to use the
# Google modules then there is always backwards compatibility with the older tags.

terraform {
  source = "git::ssh://git@github.com/${local.repo_owner}/pt1-training-project-1-modules.git//project?ref=${local.version}"
}

# -------------------------------- INCLUDE ----------------------------------------------------#

# The include block here is used to import terragrunt configuration files. I think
# this is the same as the import keyword in python or the include keyword in c++. It's
# used to include/import packages within the codebase.

# In this instance, the find_in_parent_folders() function searches up the folder structure.
# Having it within the include block here just means it can be used elsewhere within the file.

include {
  path = find_in_parent_folders()
}
