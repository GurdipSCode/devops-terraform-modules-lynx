#------------------------------------------------------------------------------
# Lynx Terraform Module - Version Constraints
#------------------------------------------------------------------------------
# This file defines the required Terraform and provider versions.
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
# Version Compatibility Notes
#------------------------------------------------------------------------------
#
# Terraform:
#   - Minimum version: 1.0.0
#   - Tested with: 1.5.x, 1.6.x, 1.7.x, 1.8.x
#
# Lynx Provider:
#   - Minimum version: 0.3.0
#   - Provider source: Clivern/lynx
#   - Registry: https://registry.terraform.io/providers/Clivern/lynx
#
# Lynx Backend:
#   - Compatible with Lynx v1.x
#   - GitHub: https://github.com/Clivern/Lynx
#   - Documentation: https://lynx.clivern.com/
#
#------------------------------------------------------------------------------
