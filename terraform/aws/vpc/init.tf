terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
    default = "eu-west-3"
}

variable "cluster_name" {
    default = "weather-cluster"
}
