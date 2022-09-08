
provider "aws" {
  region = var.aws_region
}

# CodeArtifact resources

resource "aws_codeartifact_domain" "codeartifact-domain" {
  domain = var.domain_name
}

resource "aws_codeartifact_domain_permissions_policy" "artifact-domain-policy" {
  domain = aws_codeartifact_domain.codeartifact-domain.domain
  policy_document = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ContributorPolicy",
        "Action" : [
          "codeartifact:CreateRepository",
          "codeartifact:DeleteDomain",
          "codeartifact:DeleteDomainPermissionsPolicy",
          "codeartifact:DescribeDomain",
          "codeartifact:GetAuthorizationToken",
          "codeartifact:GetDomainPermissionsPolicy",
          "codeartifact:ListRepositoriesInDomain",
          "codeartifact:PutDomainPermissionsPolicy",
          "sts:GetServiceBearerToken"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })
}

resource "aws_codeartifact_repository" "artifact-repo" {
  repository = var.codeartifact_repository_name
  domain     = aws_codeartifact_domain.codeartifact-domain.domain
}

resource "aws_codeartifact_repository_permissions_policy" "artifact-repo-policy" {
  repository = aws_codeartifact_repository.artifact-repo.repository
  domain     = aws_codeartifact_domain.codeartifact-domain.domain
  policy_document = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "codeartifact:DescribePackageVersion",
          "codeartifact:DescribeRepository",
          "codeartifact:GetPackageVersionReadme",
          "codeartifact:GetRepositoryEndpoint",
          "codeartifact:ListPackageVersionAssets",
          "codeartifact:ListPackageVersionDependencies",
          "codeartifact:ListPackageVersions",
          "codeartifact:ListPackages",
          "codeartifact:PublishPackageVersion",
          "codeartifact:PutPackageMetadata",
          "codeartifact:ReadFromRepository"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })
}

# CodeCommit resources

resource "aws_codecommit_repository" "app-repo" {
  repository_name = var.codecommit_repo_name
  default_branch  = var.codecommit_repo_default_branch
}

# CodeBuild Resources
resource "aws_iam_role" "codebuild-role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild-policy" {
  role = aws_iam_role.codebuild-role.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
       "s3:PutObject",
       "s3:GetObject",
       "s3:GetObjectVersion",
       "s3:GetBucketVersioning"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Effect": "Allow",
      "Resource": [
        "${aws_codebuild_project.build-project.id}"
      ],
      "Action": [
        "codebuild:*"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [ 
        "codeartifact:GetAuthorizationToken",
        "codeartifact:GetRepositoryEndpoint",
        "codeartifact:ReadFromRepository",
        "codeartifact:PublishPackageVersion",
        "codeartifact:PutPackageMetadata"
        ],
      "Resource": "*"
      },
      {       
        "Effect": "Allow",
        "Action": "sts:GetServiceBearerToken",
        "Resource": "*",
        "Condition": {
          "StringEquals": {
            "sts:AWSServiceName": "codeartifact.amazonaws.com"
          }
        }
      }
  ]
}
POLICY
}

resource "aws_codebuild_project" "build-project" {
  name         = var.build_project_name
  service_role = aws_iam_role.codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = var.build_compute_type
    image        = var.build_image
    type         = var.build_type

    environment_variable {
      name  = "CODEARTIFACT_DOMAIN_NAME"
      value = aws_codeartifact_domain.codeartifact-domain.domain
    }

    environment_variable {
      name  = "CODEARTIFACT_OWNER_ACCOUNT"
      value = aws_codeartifact_domain.codeartifact-domain.owner
    }

    environment_variable {
      name  = "CODEARTIFACT_REPO_URL"
      value = data.aws_codeartifact_repository_endpoint.codeartifact-endpoint.repository_endpoint
    }
  }

  source {
    type = "CODEPIPELINE"
  }
}

# CodePipeline resources

resource "aws_s3_bucket" "build-artifact-bucket" {
}

resource "aws_iam_role" "codepipeline-role" {
  assume_role_policy = data.aws_iam_policy_document.codepipeline-assume-policy.json
}

resource "aws_iam_role_policy" "codepipeline-policy" {
  role = aws_iam_role.codepipeline-role.id

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketVersioning",
                "s3:PutObject"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codecommit:CancelUploadArchive",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:UploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_codepipeline" "codepipeline" {
  name     = var.pipeline_name
  role_arn = aws_iam_role.codepipeline-role.arn

  artifact_store {
    location = aws_s3_bucket.build-artifact-bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        RepositoryName = var.codecommit_repo_name
        BranchName     = var.codecommit_repo_default_branch
      }
    }
  }

  stage {
    name = "BuildAndPublish"

    action {
      name             = "BuildAndPublish"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      output_artifacts = ["built"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build-project.name
      }
    }
  }
}
