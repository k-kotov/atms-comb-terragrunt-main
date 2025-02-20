dependency "twingate_ecs_connectors" {
  config_path = "${get_original_terragrunt_dir()}/../twingate-ecs-connectors"

  mock_outputs = {
    twingate_security_group_id = "mock-id"
  }
}