dependency "vpc" {
  config_path = "${get_original_terragrunt_dir()}/../vpc"

  mock_outputs = {
    azs = tolist([
      "us-east-1a",
    ])
    cluster_name = "mock-123"
    database_subnet_ids = [
      "subnet-123",
    ]
    database_subnets = {
      "subnet-789" = {
        "availability_zone"    = "us-east-1a"
        "availability_zone_id" = "use1-az1"
        "id"                   = "subnet-789"
      }
    }
    database_subnet_group      = "sg-123"
    database_subnet_group_name = "mock-123"
    intra_subnet_ids = [
      "subnet-456",
    ]
    intra_subnets = {
      "subnet-789" = {
        "availability_zone"    = "us-east-1a"
        "availability_zone_id" = "use1-az1"
        "id"                   = "subnet-789"
      }
    }
    name_prefix = "re-dev-1593855f"
    nat_public_ips = [
      "1.2.3.4"
    ]
    private_subnet_ids = [
      "subnet-789",
    ]
    private_subnets = {
      "subnet-789" = {
        "availability_zone"    = "us-east-1a"
        "availability_zone_id" = "use1-az1"
        "id"                   = "subnet-789"
      }
    }
    public_subnet_ids = [
      "subnet-012",
    ]

    tags = {
      "Client"      = "mock"
      "Component"   = "mock"
      "Environment" = "mock"
      "Project"     = "mock"
      "uid"         = "mock-123"
    }
    uid            = "123"
    vpc_cidr_block = "10.0.0.0/16"
    vpc_id         = "vpc-123"
  }
}