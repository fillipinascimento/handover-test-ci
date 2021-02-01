terraform {
  backend "s3" {
    bucket         = "handover-teste-devops-tfstate"
    key            = "handover-teste.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "handover-teste-devops-tf-state-lock"
  }
}

provider "aws" {
  region = "us-east-2"
}

locals {
  prefix = "${var.prefix}-${terraform.workspace}"
  common_tags = {
    Environment = terraform.workspace
    Project     = var.project
    Owner       = var.contact
    ManagedBy   = "Terraform"
  }
}

data "aws_region" "current" {}
