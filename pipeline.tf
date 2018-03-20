provider "aws" {
  region = "us-east-1"
  version = ">=1.9.0"
}

resource "aws_s3_bucket" "template" {
  bucket = "slick-nicks-test-bucket"
  acl    = "private"
}

resource "aws_iam_role" "template" {
  name = "template-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = "${aws_iam_role.template.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.template.arn}",
        "${aws_s3_bucket.template.arn}/*"
      ]
    },
    {
      "Effect":"Allow",
      "Action": [
        "s3:*",
        "lambda:ListFunctions",
        "lambda:ListVersionsByFunction",
        "lambda:GetEventSourceMapping",
        "lambda:ListTags",
        "lambda:GetFunction",
        "lambda:ListAliases",
        "lambda:ListEventSourceMappings",
        "lambda:GetAccountSettings",
        "lambda:GetFunctionConfiguration",
        "lambda:GetAlias",
        "lambda:GetPolicy",
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "${var.aws_lambda_function}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_codepipeline" "template" {
  name     = "tf-template-pipeline"
  role_arn = "${aws_iam_role.template.arn}"

  artifact_store {
    location = "${aws_s3_bucket.template.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["MyApp"]

      configuration {
        Owner      = "steph-query"
        Repo       = "craft-serverless-template"
        Branch     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["MyApp"]
      output_artifacts = ["MyAppBuild"]
      version         = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.template.name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Invoke"
      owner           = "AWS"
      provider        = "Lambda"
      input_artifacts = ["MyAppBuild"]
      version         = "1"

      configuration {
        FunctionName = "${var.aws_lambda_function}"
      }
    }
  }
}
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role-template"

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

resource "aws_iam_policy" "codebuild_policy" {
  name        = "codebuild-policy"
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodeBuild"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
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
      "Effect":"Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.template.arn}",
        "${aws_s3_bucket.template.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  name       = "codebuild-policy-attachment"
  policy_arn = "${aws_iam_policy.codebuild_policy.arn}"
  roles      = ["${aws_iam_role.codebuild_role.id}"]
}

resource "aws_codebuild_project" "template" {
  name         = "codebuild_template"
  description  = "test_codebuild_project"
  build_timeout      = "15"
  service_role = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:6.3.1"
    type         = "LINUX_CONTAINER"
  }

  source {
    type     = "CODEPIPELINE"
  }

  tags {
    "Environment" = "Test"
  }
}



variable "aws_lambda_function" {
}
