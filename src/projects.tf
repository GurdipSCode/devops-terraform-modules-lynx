#------------------------------------------------------------------------------
# Lynx Project Resources
#------------------------------------------------------------------------------
# Projects represent distinct infrastructure configurations within a team.
#
# Each project can contain multiple environments, allowing you to manage
# separate Terraform states for different stages (dev, staging, prod).
#
# Project structure:
# - Team
#   └── Project (e.g., "web-app")
#       ├── Environment (e.g., "dev")
#       ├── Environment (e.g., "staging")
#       └── Environment (e.g., "prod")
#------------------------------------------------------------------------------

resource "lynx_project" "this" {
  for_each = var.projects

  name        = each.value.name != "" ? each.value.name : each.key
  slug        = local.project_slugs[each.key]
  description = each.value.description

  team = {
    id = local.team_id
  }

  depends_on = [
    lynx_team.this
  ]

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# Project ID Map
#------------------------------------------------------------------------------

locals {
  # Map of project keys to their IDs
  project_id_map = {
    for key, project in lynx_project.this : key => project.id
  }

  # Map of project keys to their slugs
  project_slug_map = {
    for key, project in lynx_project.this : key => project.slug
  }
}
