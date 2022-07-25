variable "region" {
  type = string
  description = "The region to use for the stack"
  default = "us-east-1"
}

variable "account_id"{
  type        = string
  description = "The account ID in which to create/manage resources"
  default = "155516267556"
}