variable "name" {
  description = "The name of the lambda to create, which also defines (i) the archive name (.zip), (ii) the file name, and (iii) the function name"
}

variable "runtime" {
  description = "The runtime of the lambda to create"
  default     = "nodejs"
}

variable "handler" {
  description = "The handler name of the lambda (a function defined in your lambda)"
  default     = "handler"
}

variable "role" {
  description = "IAM role attached to the Lambda Function (ARN)"
}

variable "environment" {
  type = "map"
  default = {}
}

variable "timeout" {
  type = "string"
  default = "10"
}
