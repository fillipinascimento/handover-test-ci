variable "prefix" {
  default = "handover-test"
}

variable "project" {
  default = "handover-test"
}

variable "contact" {
  default = "fillipi.nascimento@oihandover.com"
}

variable "ecr_image_test" {
  description = "ECR Image for Teste"
  default     = "962371430049.dkr.ecr.us-east-2.amazonaws.com/handover-teste:latest"
}

