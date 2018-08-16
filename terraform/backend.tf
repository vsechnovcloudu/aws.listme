terraform {
  backend "s3" {
    bucket = "vvc.listme.ops"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}
