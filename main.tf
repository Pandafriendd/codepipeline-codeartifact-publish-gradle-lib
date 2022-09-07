module "cicd_infra" {
  source = "./modules/cicd-infra"

  codeartifact_repository_name = "APG_Artifact_Repo_lizhiyua"
  codecommit_repo_name = "APG_App_Repo_lizhiyua"
  build_project_name = "APG_Build_lizhiyua"
  pipeline_name = "APG_Pipeline_lizhiyua"
}