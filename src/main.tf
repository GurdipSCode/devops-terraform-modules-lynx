#------------------------------------------------------------------------------
# Lynx Terraform Module - Main Configuration
#------------------------------------------------------------------------------
# This module manages Lynx Terraform Backend infrastructure including:
# - Users (admin and regular)
# - Teams with member assignments
# - Projects within teams
# - Environments within projects (with Terraform state backend config)
# - Snapshots for backup and recovery
#
# Lynx is a Fast, Secure and Reliable Terraform Backend by Clivern
# https://github.com/Clivern/Lynx
#------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    lynx = {
      source  = "Clivern/lynx"
      version = ">= 0.3.0"
    }
  }
}

#------------------------------------------------------------------------------
# Local Values
#------------------------------------------------------------------------------

locals {
  # Generate team slug if not provided
  team_slug = var.team_slug != "" ? var.team_slug : lower(replace(var.team_name, " ", "-"))

  # Collect all user IDs for team membership
  all_user_ids = [for name, user in lynx_user.this : user.id]

  # Generate project slugs
  project_slugs = {
    for name, project in var.projects :
    name => project.slug != "" ? project.slug : lower(replace(name, " ", "-"))
  }
}
