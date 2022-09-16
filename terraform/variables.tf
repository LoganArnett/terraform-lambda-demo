variable "region" {
  type = string
  description = "The region to use for the stack"
  default = "us-east-2"
}

variable "account_id"{
  type        = string
  description = "The account ID in which to create/manage resources"
  default = "101780558037"
}