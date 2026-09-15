#------------------------------------------------------------------------------
# Lynx User Resources
#------------------------------------------------------------------------------
# Users are the foundation of Lynx access control.
# 
# User roles:
# - admin: Full access to all features, can manage teams and users
# - regular: Standard access, can work within assigned teams
#
# Users must be added to teams to access projects and environments.
#------------------------------------------------------------------------------

resource "lynx_user" "this" {
  for_each = var.users

  name     = each.value.name
  email    = each.value.email
  role     = each.value.role
  password = each.value.password

  lifecycle {
    # Prevent password from being logged
    ignore_changes = []
  }
}

#------------------------------------------------------------------------------
# Computed Values for Users
#------------------------------------------------------------------------------

locals {
  # Map of user keys to their IDs
  user_id_map = {
    for key, user in lynx_user.this : key => user.id
  }

  # Determine which users to add to the team
  team_member_ids = var.auto_add_users_to_team ? local.all_user_ids : [
    for key in var.team_members : local.user_id_map[key]
    if contains(keys(local.user_id_map), key)
  ]
}
