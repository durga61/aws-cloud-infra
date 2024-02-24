resource "aws_appconfig_environment" "develop" {
  name           = "dev"
  description    = "Dev AppConfig Environment"
  application_id = aws_appconfig_application.v_app.id
  tags = {
    Type = "Dev AppConfig Environment"
  }
}
resource "aws_appconfig_hosted_configuration_version" "develop" {
  application_id  = aws_appconfig_application.v_app.id
  configuration_profile_id = aws_appconfig_configuration_profile.develop.configuration_profile_id
  description   = "Dev Hosted Configuration Version"
  content_type             = "application/json"
  content = jsonencode({
    Environment = "dev",
    BillingUnit = "CompanyName",
    isThingEnabled = true,
    database_user = "database user",
    database_password = "database password",
    new_var = "new_var",
    new_var2 = "new_var2"
  })
}