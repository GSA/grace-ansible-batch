variable "ecr_name" {
  type        = string
  description = "(required) The name of the ECR Repository"
  default     = "ansible"
}

variable "scan_image" {
  type        = bool
  description = "(required) The boolean value indicating whether to enable scan_on_push feature"
  default     = true
}

variable "tag_prefix_list" {
  type        = list(string)
  description = "(required) The list of tag prefixes used for the ECR lifecycle policy"
  default     = ["ansible-"]
}

variable "max_image_count" {
  type        = number
  description = "(required) The maximum number of tagged images to maintain in the repository without expiring"
  default     = 2
}

variable "expiration_days" {
  type        = number
  description = "(required) The number of days used to determine when an image will expire once pushed"
  default     = 30
}

variable "subnets" {
    type = list(string)
    description = "The subnet IDs to be used by the AWS Batch compute environment"
}

variable "instance_types" {
  type        = list(string)
  description = "(optional) A list of instance types to be used for the batch"
  default     = ["t2.micro"]
}

variable "max_vcpus" {
  type        = number
  description = "(optional) The maximum vCPUs required by the batch job"
  default     = 1
}

variable "min_vcpus" {
  type        = number
  description = "(optional) The minimum vCPUs required by the batch job"
  default     = 0
}

