# -------------------------------- INPUTS ----------------------------------------------------#

# I've removed all of the inputs bar the project to explain dependencies.

# There are going to be times when you need information from something else to continue.
# If trying to create a network manually then these steps would probably be followed:
#     1. Create project
#     2. Create a vpc within the project

# The problem when using a terragrunt workflow is that everything is defined at the same time.
# When the code is run there's no way to know what the project_id is going to be

# Therefore, the vpc is dependent on information about the project, namely the id of the project

# What this means from a technical perspective is that there has to be a way to get information
# about the project _before_ the project has actually been created

# Thats where the dependency block comes in
# The dependency block can help you include information based on outputs from modules. You usually
# find these when the terragrunt config you're in is dependent on some information from another
# module. It creates an abstraction of the information you need, i.e. it will be whatever the value
# _eventually_ is. This means that the vpc's dependency on the project_id will not break the code.

# In this case the vpc needs to know the project that it is going to be created in. We know that 
# within the project module it is outputting a lot of information. This can then be used here. What
# we really need to know is the project_id so Terraform can create the vpc. In the project module we
# know this has been defined as "project_id" and therefore can be referenced like:
#     dependency.host_project.outputs.project.project_id

# To break that down...
#     dependency   - defines that it is looking for an output from a dependency block
#     host_project - this is the name of the dependency block
#     outputs      - this is stating it is looking specifically for an output
#     project      - this is the name of the output within the project module
#     project_id   - this is the name of the attribute we are looking for.

# Furthermore, if the vpc needed the org_id to run then this could be referenced like:
#     dependency.host_project.outputs.project.org_id


inputs = {
  project = dependency.host_project.outputs.project.project_id
}

# -------------------------------- LOCALS ----------------------------------------------------#

# This is the same as the locals block in project/terragrunt.hcl

locals {
  default_yaml_path = find_in_parent_folders("empty.yaml")
  root_vars         = yamldecode(file(find_in_parent_folders("root.yaml", local.default_yaml_path)))
  vars              = yamldecode(file(find_in_parent_folders("env.yaml", local.default_yaml_path)))
  version           = local.vars.version
  repo_owner        = local.root_vars.repo_owner
}

# -------------------------------- DEPENDENCY ----------------------------------------------------#

# The dependency here has a config_path that points to the terragrunt.hcl of the dependency. Here,
# it is pointing to the project folder which contains project/terragrunt.hcl

# The mock_outputs section contains information that will be used if terragrunt can't find the 
# necessary information from the output.

# For example, here the vpc needs the project_id. We know that this attribute is being outputted from
# the project module. However, if for some reason this couldn't be found then it would revert to using
# the values from the mock_outputs block. Since we are only interested in the project_id then we only
# need to provide a value for this attribute. Following on from the previous example - about it 
# needing the org_id attribute - then underneath project_id would also be org_id.

# (I'm assuming) the naming needs to be the same as what is defined in the line:
#     dependency.host_project.outputs.project.project_id

# What I mean here is that within mock_outputs it would have to follow the project.project_id syntax
# and couldn't be something like:
#     dependency "host_project" {
#         config_path = "../project"

#         mock_outputs = {
#             project_output = {
#             project_id_output = "project-mock-name-01" }
#         }
#     }

# This is because it is looking for project.project_id and not project_output.project_id_output

dependency "host_project" {
  config_path = "../project" # This refers to the project-module as its dependency to create a VPC

  mock_outputs = {
    project = {
    project_id = "project-mock-name-01" }
  }
}

terraform {
  source = "git::ssh://git@github.com/${local.repo_owner}/pt1-training-project-1-modules.git//vpc?ref=${local.version}"
}

include {
  path = find_in_parent_folders()
}
