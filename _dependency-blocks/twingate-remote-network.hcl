dependency "twingate_remote_network" {
  config_path = "${get_original_terragrunt_dir()}/../twingate-remote-network"

  mock_outputs = {
    twingate_remote_network_id   = "mock-id"
    twingate_remote_network_name = "mock-name"
  }
}