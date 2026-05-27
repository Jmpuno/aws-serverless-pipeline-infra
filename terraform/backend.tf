terraform {
  backend "s3" {
    bucket = "matt-tfstate-bucket"
     key   = "environments/dev/terraform.tfstate"
    region = "ap-southeast-1"
    encrypt = true
    use_lockfile = true


  }

   
}


