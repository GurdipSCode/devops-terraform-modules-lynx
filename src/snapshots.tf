#------------------------------------------------------------------------------
# Lynx Snapshot Resources
#------------------------------------------------------------------------------
# Snapshots provide backup and recovery capabilities for Lynx.
#
# Snapshot types:
# - project: Snapshot of an entire project and all its environments
# - environment: Snapshot of a specific environment's state
#
# Snapshots capture the current state and can be used to:
# - Create backups before major changes
# - Restore infrastructure to a known good state
# - Audit historical configurations
#------------------------------------------------------------------------------

# Parse snapshot references
locals {
  snapshots_resolved = {
    for key, snapshot in var.snapshots : key => {
      title       = snapshot.title
      description = snapshot.description
      record_type = snapshot.record_type
      record_id = snapshot.record_type == "project" ? (
        local.project_id_map[snapshot.record_key]
      ) : (
        local.environment_id_map[snapshot.record_key]
      )
    }
  }
}

resource "lynx_snapshot" "this" {
  for_each = local.snapshots_resolved

  title       = each.value.title
  description = each.value.description
  record_type = each.value.record_type
  record_id   = each.value.record_id

  team = {
    id = local.team_id
  }

  depends_on = [
    lynx_team.this,
    lynx_project.this,
    lynx_environment.this
  ]

  lifecycle {
    create_before_destroy = true
  }
}
