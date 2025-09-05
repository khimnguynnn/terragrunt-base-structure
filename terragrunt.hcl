remote_state {
  backend = "s3"
  config = {
    bucket         = "terraform-backend-bucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "st-point-terraform-lock-table"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
