output "clone_repo_https" {
  value = "${module.cicd_infra.repo_https}"
}

output "clone_repo_ssh" {
  value = "${module.cicd_infra.repo_ssh}"
}

output "artifact_bucket" {
  value = "${module.cicd_infra.artifact_bucket}"
}