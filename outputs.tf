output "clone_repo_https" {
  value = "${module.cicd_infra.repo_https}"
}

output "clone_repo_ssh" {
  value = "${module.cicd_infra.repo_ssh}"
}

output "codeartifact_repository_endpoint" {
  value = "${module.cicd_infra.codeartifact_repository_endpoint}"
}