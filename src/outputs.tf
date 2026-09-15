#------------------------------------------------------------------------------
# Lynx Terraform Module - Outputs
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# User Outputs
#------------------------------------------------------------------------------

output "user_ids" {
  description = "Map of user keys to their Lynx IDs."
  value       = local.user_id_map
}

output "user_details" {
  description = "Detailed information about each user (excluding sensitive data)."
  value = {
    for key, user in lynx_user.this : key => {
      id    = user.id
      name  = user.name
      email = user.email
      role  = user.role
    }
  }
}

#------------------------------------------------------------------------------
# Team Outputs
#------------------------------------------------------------------------------

output "team_id" {
  description = "The ID of the team."
  value       = local.team_id
}

output "team_slug" {
  description = "The slug of the team."
  value       = local.resolved_team_slug
}

output "team_details" {
  description = "Detailed information about the team."
  value = var.create_team && length(lynx_team.this) > 0 ? {
    id          = lynx_team.this[0].id
    name        = lynx_team.this[0].name
    slug        = lynx_team.this[0].slug
    description = lynx_team.this[0].description
    member_count = length(local.team_member_ids)
  } : null
}

#------------------------------------------------------------------------------
# Project Outputs
#------------------------------------------------------------------------------

output "project_ids" {
  description = "Map of project keys to their Lynx IDs."
  value       = local.project_id_map
}

output "project_slugs" {
  description = "Map of project keys to their slugs."
  value       = local.project_slug_map
}

output "project_details" {
  description = "Detailed information about each project."
  value = {
    for key, project in lynx_project.this : key => {
      id          = project.id
      name        = project.name
      slug        = project.slug
      description = project.description
    }
  }
}

#------------------------------------------------------------------------------
# Environment Outputs
#------------------------------------------------------------------------------

output "environment_ids" {
  description = "Map of environment keys (project/env) to their Lynx IDs."
  value       = local.environment_id_map
}

output "environment_details" {
  description = "Detailed information about each environment (excluding secrets)."
  value = {
    for key, env in lynx_environment.this : key => {
      id       = env.id
      name     = env.name
      slug     = env.slug
      username = env.username
      # Note: secret is intentionally excluded
    }
  }
}

#------------------------------------------------------------------------------
# Terraform Backend Configuration Outputs
#------------------------------------------------------------------------------

output "backend_configs" {
  description = "Terraform HTTP backend configurations for each environment."
  value = {
    for key, env in local.environments_map : key => {
      address        = "${var.lynx_base_url}/client/${local.resolved_team_slug}/${local.project_slug_map[env.project_key]}/${env.slug}/state"
      lock_address   = "${var.lynx_base_url}/client/${local.resolved_team_slug}/${local.project_slug_map[env.project_key]}/${env.slug}/lock"
      unlock_address = "${var.lynx_base_url}/client/${local.resolved_team_slug}/${local.project_slug_map[env.project_key]}/${env.slug}/unlock"
      lock_method    = "POST"
      unlock_method  = "POST"
      username       = env.username
    }
  }
  sensitive = true
}

output "backend_config_hcl" {
  description = "Ready-to-use Terraform backend HCL configurations for each environment."
  value = {
    for key, env in local.environments_map : key => <<-EOT
      # Terraform Backend Configuration for ${env.name}
      # Project: ${env.project_key}, Environment: ${env.slug}
      #
      # Set these environment variables before running terraform:
      #   export TF_HTTP_USERNAME="${env.username}"
      #   export TF_HTTP_PASSWORD="<your-secret>"
      
      terraform {
        backend "http" {
          address        = "${var.lynx_base_url}/client/${local.resolved_team_slug}/${local.project_slug_map[env.project_key]}/${env.slug}/state"
          lock_address   = "${var.lynx_base_url}/client/${local.resolved_team_slug}/${local.project_slug_map[env.project_key]}/${env.slug}/lock"
          unlock_address = "${var.lynx_base_url}/client/${local.resolved_team_slug}/${local.project_slug_map[env.project_key]}/${env.slug}/unlock"
          lock_method    = "POST"
          unlock_method  = "POST"
        }
      }
    EOT
  }
}

#------------------------------------------------------------------------------
# Snapshot Outputs
#------------------------------------------------------------------------------

output "snapshot_ids" {
  description = "Map of snapshot keys to their Lynx IDs."
  value = {
    for key, snapshot in lynx_snapshot.this : key => snapshot.id
  }
}

output "snapshot_details" {
  description = "Detailed information about each snapshot."
  value = {
    for key, snapshot in lynx_snapshot.this : key => {
      id          = snapshot.id
      title       = snapshot.title
      description = snapshot.description
      record_type = snapshot.record_type
    }
  }
}

#------------------------------------------------------------------------------
# Summary Output
#------------------------------------------------------------------------------

output "summary" {
  description = "Summary of all created resources."
  value = {
    users = {
      count = length(lynx_user.this)
      names = [for u in lynx_user.this : u.name]
    }
    team = var.create_team ? {
      name = var.team_name
      slug = local.resolved_team_slug
    } : null
    projects = {
      count = length(lynx_project.this)
      names = [for p in lynx_project.this : p.name]
    }
    environments = {
      count = length(lynx_environment.this)
      names = [for e in lynx_environment.this : e.name]
    }
    snapshots = {
      count = length(lynx_snapshot.this)
      titles = [for s in lynx_snapshot.this : s.title]
    }
  }
}
