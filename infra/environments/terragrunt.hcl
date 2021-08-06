# -------------------------------- LOCALS ----------------------------------------------------#


# The locals block contains variables
# that are within the scope of this file.
# This means that they can only used and referenced
# within this terragrunt file.

locals {
  default_yaml_path        = find_in_parent_folders("empty.yaml", "empty.yaml")
  root_vars                = yamldecode(file(find_in_parent_folders("root.yaml", local.default_yaml_path))) # This is located in the same level of the directory
  project_factory_project  = local.root_vars.project_factory_project
  project_factory_bucket   = "${local.root_vars.project_factory_project}-tfstate"
  project_factory_location = local.root_vars.region
  extra_tf_cmds            = ["plan", "apply", "import", "push", "refresh", "destroy", "init"]
}

# root_vars is defined because it is needed for:
#     project_factory_project
#     project_factory_bucket
#     project_factory_location

# You know this is the case because they reference root_vars

# -------------------------------- INPUTS ----------------------------------------------------#

# The inputs here are read from the root.yaml file and the env.yaml file at the root level

# The inputs within this root level terragrunt config file will permeate
# down the folder structure. Therefore anything that is within this inputs block
# will be in all input blocks further down the folder structure.

# This means that the inputs block for infra/environments/dev/project already has all 
# the inputs from this terragrunt file already.

# A note on the functionality of yamldecode - 
#     the docs are here: https://www.terraform.io/docs/language/functions/yamldecode.html

# It takes yaml code and represents it like:
#     yamldecode("{\"hello\": \"world\"}")

#     =

#     {
#       "hello" = "world"
#     }



# A note on the functionality of merge - 
#     the docs are here: https://www.terraform.io/docs/language/functions/merge.html

# The docs show an example:
#     merge({a="b", c="d"}, {e="f", c="z"})

#     =

#     {
#       "a" = "b"
#       "c" = "z"
#       "e" = "f"
#     }

# When put together, they translate the root.yaml code and the env.yaml code into another 
# representation of key/value pairs and then merge those key/value pairs into one big 
# set which can be used for the inputs

inputs = merge(
  yamldecode(file(find_in_parent_folders("root.yaml", local.default_yaml_path))),
  yamldecode(file(find_in_parent_folders("env.yaml", local.default_yaml_path))),
)

# -------------------------------- GENERATE ----------------------------------------------------#

# These generate blocks will generate a provider.tf file and a versions.tf file if one does 
# not already exist.


generate "provider" {
  path      = "provider.tf"
  if_exists = "skip"
  contents  = file(find_in_parent_folders("provider.tf"))
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "skip"
  contents  = file(find_in_parent_folders("versions.tf"))
}

# -------------------------------- REMOTE_STATE ----------------------------------------------------#

# This is where the remote state for Terraform is configured. It should be using the project_factory
# project to store the state and ensure that each state file is within the right directory.

remote_state {
  backend = "gcs"
  config = {
    bucket   = local.project_factory_bucket
    prefix   = path_relative_to_include()
    project  = local.project_factory_project
    location = local.project_factory_location
  }
}
