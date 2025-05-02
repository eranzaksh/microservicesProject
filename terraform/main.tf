terraform {
  required_version = ">= 1.2"
  backend "s3" {
    bucket = "microservices-terraform-state-bucket"
    key    = "terraform.tfstate"
    region = "eu-north-1"
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source              = "./modules/vpc"
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs= var.private_subnet_cidrs
}

module "ecs" {
  source = "./modules/ecs"
  private_subnets = var.private_subnet_cidrs
}