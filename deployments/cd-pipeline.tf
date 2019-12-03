# The codebuild stage is used for creating an artifact that is pushed to s3
# that will be used as the application version for elastic beanstalk
resource "aws_codebuild_project" "build" {
  name          = local.project_name
  description   = "Builds the client files for the ${local.project_name} environment."
  build_timeout = "15"
  service_role  = aws_iam_role.build.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  # Utilize a public dockerhub ruby image. The default linux container type with the ruby
  # runtime didn't have the correct ruby version installed.
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "ruby:${local.ruby_version}"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "S3_BUCKET"
      value = aws_s3_bucket.artifacts.bucket
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

# The codepipeline creates a continuous delivery pipeline to build and deploy changes
# checked into a single branch. It seems it doestn't have the capability to watch multiple
# branches in order to do branch deploys
resource "aws_codepipeline" "pipeline" {
  # Don't build the code pipeline until the beanstalk application is running so the public succeeds
  depends_on = [aws_elastic_beanstalk_application.app]
  name     = "${local.project_name}-pipeline"
  role_arn = aws_iam_role.build.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    # TODO: I'm still not clear how this is getting the changes. My guess is by default its using polling
    # using the oauth token. There is a terraform resource for a github webhook, but none of the examples
    # online seem to use it.
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      # The github oauth token is a variable because it needs to be passed in as a secret
      configuration = {
        OAuthToken = var.github_oauth_token
        Owner      = local.github_organization
        Repo       = local.github_repository
        Branch     = local.github_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      output_artifacts = ["artifact"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ElasticBeanstalk"
      input_artifacts = ["artifact"]
      version         = "1"

      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.app.name
        EnvironmentName = aws_elastic_beanstalk_environment.prod.name
      }
    }
  }
}