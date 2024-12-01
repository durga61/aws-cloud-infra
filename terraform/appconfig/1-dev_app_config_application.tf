resource "aws_appconfig_application" "v_app" {
  name        = "v_app_config_poc"
  description = "PoC for testing AppConfig Application"
  tags = {
    Type        = "AppConfig Application"
    Environment = "Dev"
  }
}
resource "aws_appconfig_configuration_profile" "develop" {
  application_id = aws_appconfig_application.v_app.id
  description    = "Dev Configuration Profile"
  name           = "dev-profile"
  location_uri   = "hosted"

  tags = {
    Type        = "Dev AppConfig Configuration Profile"
    Environment = "Dev"
  }
}
