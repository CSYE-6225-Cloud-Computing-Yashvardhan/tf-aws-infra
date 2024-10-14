terraform {
  required_providers {
                    aws = {
        = "hashicorp/aws"
      version = ">5.0.0, <6.0.0"
    }
  }

  required_version = ">= 1.9.0"
}
