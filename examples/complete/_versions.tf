terraform {
  required_version = ">= 1.1.5"
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "=> 2.8.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "=> 4.12.1"
    }
  }
}
