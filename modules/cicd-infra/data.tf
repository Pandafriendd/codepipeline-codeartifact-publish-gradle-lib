data "aws_caller_identity" "current" {

}

data "aws_iam_policy_document" "codepipeline-assume-policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_codeartifact_repository_endpoint" "codeartifact-endpoint" {
  domain     = aws_codeartifact_domain.codeartifact-domain.domain
  repository = aws_codeartifact_repository.artifact-repo.repository
  format     = "maven"
}