terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.85.0"
    }

    twingate = {
      source  = "twingate/twingate"
      version = "3.0.15"
    }
  }
}
