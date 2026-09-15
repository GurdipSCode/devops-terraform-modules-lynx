#------------------------------------------------------------------------------
# Lynx Environment Resources
#------------------------------------------------------------------------------
# Environments represent distinct Terraform state backends within a project.
#
# Each environment has:
# - name: Display name (e.g., "Production")
# - slug: URL-friendly identifier (e.g., "prod")
# - username: Authentication username for the backend
# - secret: Authentication secret/password for the backend
#
# The environment provides the Terraform HTTP backend configuration:
#   terraform {
#     backend "http" {
#       address        = "http://lynx:4000/client/{team}/{project}/{env}/state"
#       lock_address   = "http://lynx:4000/client/{team}/{project}/{env}/lock"
#       unlock_address = "http://lynx:4000/client/{team}/{project}/{env}/unlock"
#       lock_method    = "POST"
#       unlock_method  = "POST"
#     }
#   }
#------------------------------------------------------------------------------

# Flatten environments from all projects
locals {
  environments_flat = flatten([
    for project_key, project in var.projects : [
      for env_key, env in project.environments : {
        key         = "${project_key}/${env_key}"
        project_key = project_key
        env_key     = env_key
        name        = env.name
        slug        = env.slug != "" ? env.slug : env_key
        username    = env.username
        secret      = env.secret
      }
    ]
  ])

  environments_map = {
    for env in local.environments_flat : env.key => env
  }
}

resource "lynx_environment" "this" {
  for_each = local.environments_map

  name     = each.value.name
  slug     = each.value.slug
  username = each.value.username
  secret   = each.value.secret

  project = {
    id = local.project_id_map[each.value.project_key]
  }

  depends_on = [
    lynx_project.this
  ]

  lifecycle {
    create_before_destroy = true
    # Don't show secret changes in plan
    ignore_changes = []
  }
}

#------------------------------------------------------------------------------
# Environment ID Map
#------------------------------------------------------------------------------

locals {
  # Map of environment keys to their IDs
  environment_id_map = {
    for key, env in lynx_environment.this : key => env.id
  }
}
