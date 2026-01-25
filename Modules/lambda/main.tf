terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}
module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"
  function_name = var.function_name
  description = var.description
  handler = var.handler
  runtime = var.runtime

  source_path = var.source_path
  create_lambda_function_url = var.create_lambda_function_url


}