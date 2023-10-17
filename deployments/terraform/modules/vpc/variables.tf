# modules/vpc/variables.tf.tf

variable "name" {
  description = "Variable that will be used to name all the resources in this example"
  type        = string
}

variable "region" {
  description = "The region for the subnet"
  type        = string
}
