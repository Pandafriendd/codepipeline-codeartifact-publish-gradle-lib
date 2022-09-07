
output "repo_https" {
  value = "${aws_codecommit_repository.app-repo.clone_url_http}"
}

output "repo_ssh" {
  value = "${aws_codecommit_repository.app-repo.clone_url_ssh}"
}

output "codeartifact_repository_endpoint" {
  value = data.aws_codeartifact_repository_endpoint.codeartifact-endpoint.repository_endpoint
}

output "artifact_bucket" {
  value = "${aws_s3_bucket.build-artifact-bucket.id}"
}

output "codepipeline_role" {
  value = "${aws_iam_role.codepipeline-role.arn}"
}

output "codebuild_role" {
  value = "${aws_iam_role.codebuild-role.arn}"
}