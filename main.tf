module "cicd_infra" {
  source = "./modules/cicd-infra"

  aws_region = "us-east-2"
  codeartifact_repository_name = "Artifact_Repo_Demo"
  codecommit_repo_name = "App_Repo_Demoo"
  build_project_name = "Build_Demo"
  pipeline_name = "Pipeline_Demo"
  domain_name = "Demo"
}
