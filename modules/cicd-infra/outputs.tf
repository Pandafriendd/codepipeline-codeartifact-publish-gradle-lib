
output "repo_https" {
  value = "${aws_codecommit_repository.app-repo.clone_url_http}"
}

output "repo_ssh" {
  value = "${aws_codecommit_repository.app-repo.clone_url_ssh}"
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
