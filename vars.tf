variable "project_name" {
}

variable "s3_pipeline_bucket" {
}

variable "github_username" {
}

variable "github_repo" {
}

variable "codebuild_image" {
  default = "aws/codebuild/nodejs:6.3.1"
}

variable "site_bucket_name" {
  default = "tf-template-host-bucket"
}

variable "route53_domain_name" {
  default = "template.grassfeddata.com"
}

variable "route53_domain_zoneid" {
  default = "ZBQFLJSFKZEB4"
}

