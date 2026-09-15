#------------------------------------------------------------------------------
# Lynx Provider Configuration
#------------------------------------------------------------------------------
# The Lynx provider connects to your Lynx instance's API.
#
# Authentication:
# - api_url: The base URL of your Lynx API (e.g., http://localhost:4000/api/v1)
# - api_key: API key for authentication (get from Lynx dashboard)
#
# You can also set these via environment variables:
# - LYNX_API_URL
# - LYNX_API_KEY
#------------------------------------------------------------------------------

provider "lynx" {
  api_url = var.lynx_api_url
  api_key = var.lynx_api_key
}
