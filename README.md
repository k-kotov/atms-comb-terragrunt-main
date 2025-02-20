# City of Miami Beach Terragrunt

This project holds all of the AWS infrastructure for the ATMS COMB project.

## Requirements

OpenTofu ~> v1.8.8
Terragrunt ~> v0.71.1

## Scalr module registry

Generate a token in Scalr, then export it.

```bash
export TG_TF_REGISTRY_TOKEN=<token goes here>
```

## Provider config

### AWS

Be sure to have an AWS profile configured.

### Twingate

Set the below env vars.

* TWINGATE_TOKEN
* TWINGATE_NETWORK

## Gotchas

Data is a bit funky. Usually you'll need to prefer outputs over fetching data to prevent `run-all plan` from failing on a first run. Not sure if this is a deal breaker, it might be OK to have to run through the modules sequentially the first time.

## TODO

* Hoist VPC, twingate-ecs-connectors, twingate-remote-network modules into their own repos.
* Add Trivy
* Automate infra diagrams