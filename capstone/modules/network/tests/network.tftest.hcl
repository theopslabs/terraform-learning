mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["us-east-1a", "us-east-1b", "us-east-1c"]
    }
  }
}

run "creates_two_az_network" {
  command = plan

  variables {
    project_name       = "test-capstone"
    vpc_cidr           = "10.0.0.0/16"
    az_count           = 2
    enable_nat_gateway = false
  }

  assert {
    condition     = aws_vpc.this.cidr_block == "10.0.0.0/16"
    error_message = "The VPC should use the requested CIDR block."
  }

  assert {
    condition     = length(aws_subnet.public) == 2
    error_message = "Two public subnets should be planned."
  }

  assert {
    condition     = length(aws_subnet.private) == 2
    error_message = "Two private subnets should be planned."
  }

  assert {
    condition     = aws_subnet.public[0].cidr_block == "10.0.0.0/24"
    error_message = "The first public subnet should be 10.0.0.0/24."
  }

  assert {
    condition     = aws_subnet.private[0].cidr_block == "10.0.10.0/24"
    error_message = "The first private subnet should be 10.0.10.0/24."
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 0
    error_message = "No NAT Gateway should be planned when it is disabled."
  }
}

run "adds_nat_when_enabled" {
  command = plan

  variables {
    project_name       = "test-capstone"
    az_count           = 2
    enable_nat_gateway = true
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 1
    error_message = "One NAT Gateway should be planned when enabled."
  }

  assert {
    condition     = length(aws_eip.nat) == 1
    error_message = "One Elastic IP should be planned for the NAT Gateway."
  }

  assert {
    condition     = length(aws_route.private_nat) == 1
    error_message = "A private default route should be planned when NAT is enabled."
  }
}

run "rejects_single_az" {
  command = plan

  variables {
    project_name = "test-capstone"
    az_count     = 1
  }

  expect_failures = [var.az_count]
}
