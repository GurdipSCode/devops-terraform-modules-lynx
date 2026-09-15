#------------------------------------------------------------------------------
# Lynx Terraform Module - Variables
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Provider Configuration
#------------------------------------------------------------------------------

variable "lynx_api_url" {
  description = "Lynx API URL (e.g., http://localhost:4000/api/v1). Can also be set via LYNX_API_URL environment variable."
  type        = string
  default     = null
}

variable "lynx_api_key" {
  description = "Lynx API key for authentication. Can also be set via LYNX_API_KEY environment variable."
  type        = string
  sensitive   = true
  default     = null
}

#------------------------------------------------------------------------------
# User Configuration
#------------------------------------------------------------------------------

variable "users" {
  description = <<-EOT
    Map of users to create in Lynx.
    
    Example:
    {
      "alice" = {
        name     = "Alice Smith"
        email    = "alice@example.com"
        role     = "admin"
        password = "secure-password"
      }
      "bob" = {
        name     = "Bob Jones"
        email    = "bob@example.com"
        role     = "regular"
        password = "secure-password"
      }
    }
    
    Role can be: "admin" or "regular"
  EOT
  type = map(object({
    name     = string
    email    = string
    role     = optional(string, "regular")
    password = string
  }))
  default   = {}
  sensitive = true

  validation {
    condition = alltrue([
      for k, v in var.users : contains(["admin", "regular"], v.role)
    ])
    error_message = "User role must be either 'admin' or 'regular'."
  }
}

#------------------------------------------------------------------------------
# Team Configuration
#------------------------------------------------------------------------------

variable "create_team" {
  description = "Whether to create a team."
  type        = bool
  default     = true
}

variable "team_name" {
  description = "Display name of the team."
  type        = string
  default     = ""
}

variable "team_slug" {
  description = "URL-friendly identifier for the team. If not provided, will be generated from team_name."
  type        = string
  default     = ""
}

variable "team_description" {
  description = "Description of the team and its purpose."
  type        = string
  default     = ""
}

variable "team_members" {
  description = "List of user keys (from var.users) to add as team members. If empty and auto_add_users_to_team is true, all users will be added."
  type        = list(string)
  default     = []
}

variable "auto_add_users_to_team" {
  description = "Automatically add all created users to the team."
  type        = bool
  default     = true
}

variable "external_team_id" {
  description = "ID of an existing team to use instead of creating a new one. If set, create_team should be false."
  type        = string
  default     = null
}

#------------------------------------------------------------------------------
# Project Configuration
#------------------------------------------------------------------------------

variable "projects" {
  description = <<-EOT
    Map of projects to create within the team.
    
    Example:
    {
      "web-app" = {
        name        = "Web Application"
        slug        = "web-app"
        description = "Main web application infrastructure"
        environments = {
          "dev" = {
            name     = "Development"
            slug     = "dev"
            username = "dev-user"
            secret   = "dev-secret"
          }
          "prod" = {
            name     = "Production"
            slug     = "prod"
            username = "prod-user"
            secret   = "prod-secret"
          }
        }
      }
    }
  EOT
  type = map(object({
    name        = optional(string, "")
    slug        = optional(string, "")
    description = optional(string, "")
    environments = optional(map(object({
      name     = string
      slug     = optional(string, "")
      username = string
      secret   = string
    })), {})
  }))
  default   = {}
  sensitive = true
}

#------------------------------------------------------------------------------
# Snapshot Configuration
#------------------------------------------------------------------------------

variable "snapshots" {
  description = <<-EOT
    Map of snapshots to create for backup and recovery.
    
    Example:
    {
      "weekly-backup" = {
        title       = "Weekly Backup"
        description = "Weekly infrastructure backup"
        record_type = "project"
        record_key  = "web-app"  # Reference to project key in var.projects
      }
      "env-backup" = {
        title       = "Environment Backup"
        description = "Production environment backup"
        record_type = "environment"
        record_key  = "web-app/prod"  # Format: project_key/environment_key
      }
    }
    
    record_type can be: "project" or "environment"
  EOT
  type = map(object({
    title       = string
    description = optional(string, "")
    record_type = string
    record_key  = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.snapshots : contains(["project", "environment"], v.record_type)
    ])
    error_message = "Snapshot record_type must be either 'project' or 'environment'."
  }
}

#------------------------------------------------------------------------------
# Backend Configuration Defaults
#------------------------------------------------------------------------------

variable "lynx_base_url" {
  description = "Base URL for Lynx (used to generate backend configuration). Usually the same host as api_url but without /api/v1."
  type        = string
  default     = "http://localhost:4000"
}
