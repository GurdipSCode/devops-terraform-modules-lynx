#------------------------------------------------------------------------------
# Lynx Team Resource
#------------------------------------------------------------------------------
# Teams organize users and provide access to projects.
# 
# A team contains:
# - Members (users who can access the team's projects)
# - Projects (infrastructure configurations)
# - Snapshots (backups of projects and environments)
#
# Each project can have multiple environments (dev, staging, prod, etc.)
#------------------------------------------------------------------------------

resource "lynx_team" "this" {
  count = var.create_team ? 1 : 0

  name        = var.team_name
  slug        = local.team_slug
  description = var.team_description

  # Assign members to the team
  members = local.team_member_ids

  depends_on = [
    lynx_user.this
  ]

  lifecycle {
    # Prevent issues with member ordering
    ignore_changes = []
  }
}

#------------------------------------------------------------------------------
# Team Reference
#------------------------------------------------------------------------------

locals {
  # Resolve the team ID (either created or external)
  team_id = var.create_team ? (
    length(lynx_team.this) > 0 ? lynx_team.this[0].id : null
  ) : var.external_team_id

  # Team slug for use in outputs
  resolved_team_slug = var.create_team ? (
    length(lynx_team.this) > 0 ? lynx_team.this[0].slug : local.team_slug
  ) : var.team_slug
}
