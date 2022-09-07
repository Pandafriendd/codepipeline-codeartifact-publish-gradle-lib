variable "aws_region" {
  default = "us-east-1"
}

variable "domain_name" {
  default = "apg"
}

variable "codeartifact_repository_name" {
  default = "APG_Artifact_Repo"
}

variable "codecommit_repo_name" {
  default = "APG_App_Repo"
}

variable "codecommit_repo_default_branch" {
  default = "master"
}

variable "build_project_name" {
  default = "APG_Build"
}

variable "build_compute_type" {
  default = "BUILD_GENERAL1_LARGE"
}

variable "build_image" {
  default = "aws/codebuild/windows-base:2019-2.0"
}

variable "build_type" {
  default = "WINDOWS_SERVER_2019_CONTAINER"
}

variable "pipeline_name" {
  default = "APG_Pipeline"
}

