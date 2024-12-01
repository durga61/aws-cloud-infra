resource "aws_appconfig_deployment_strategy" "develop" {
  name                           = "develop-deployment-strategy"
  description                    = "Dev Deployment Strategy"
  deployment_duration_in_minutes = 1
  final_bake_time_in_minutes     = 1
  growth_factor                  = 20
  growth_type                    = "LINEAR"
  replicate_to                   = "NONE"
  tags = {
    Type = "Dev AppConfig Deployment Strategy"
  }
}
resource "aws_appconfig_deployment" "develop" {
  application_id           = aws_appconfig_application.v_app.id
  configuration_profile_id = aws_appconfig_configuration_profile.develop.configuration_profile_id
  configuration_version    = aws_appconfig_hosted_configuration_version.develop.version_number
  deployment_strategy_id   = aws_appconfig_deployment_strategy.develop.id
  description              = "Dev deployment"
  environment_id           = aws_appconfig_environment.develop.environment_id
  tags = {
    Type = "Dev AppConfig Deployment"
  }
}
