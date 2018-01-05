variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-2"
}

variable "s3_bucket_name" {
  type    = "string"
  default = "at-image-server-poc.at.co.uk"
}
