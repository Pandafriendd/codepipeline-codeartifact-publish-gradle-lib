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