# Automated Pipeline to Publish Java Libraries to a CodeArtifact Repo
This POC uses Terraform to provision a AWS CodeCommit repository integrated with AWS CodePipeline and CodeBuild, which demonstrates an automated pipeline for publishing Java Libraries to CodeArtifact repositories.

The CodePipeline consists of two stages:

1. A Source stage that is fed by the CodeCommit repository.
2. A Build stage that builds and publishes the Java library to CodeArtifact repository via CodeBuild

## Deploy the Infra Resources

1. Clone this repo

```
git clone {this_repo_url}
```

2. Edit the `main.tf` in the project root directory to provide a suffix to the value of each argument to differentiate your own testing environment and resources, for example, `APG_App_Repo_lizhiyua`:

```hcl
module "cicd_infra" {
  source = "./modules/cicd-infra"

  codeartifact_repository_name = "APG_Artifact_Repo_lizhiyua"
  codecommit_repo_name = "APG_App_Repo_lizhiyua"
  build_project_name = "APG_Build_lizhiyua"
  pipeline_name = "APG_Pipeline_lizhiyua"
}
```

3. Run below commends to deploy the infrastructure:

```bash
terraform init
terraform apply
```

## Commit the Java Example Library Source Code to the CodeCommit Repo
Once Terraform provisioned the infrastructure resources, you can commit the sample Java code to trigger the Pipeline. We need to get the CodeCommit Repo clone URL and CodeArtifact Repo endpoint created from the last step, which will be used in this step:

```
cd lib
```

Edit `build.gradle`'s `url` config to point to the artifact repo endpoint, for example, `https://apg-772345236255.d.codeartifact.us-east-1.amazonaws.com/maven/APG_Artifact_Repo_lizhiyua/`, and change the `version` if need:

```
publishing {
    publications {
        mavenJava(MavenPublication) {
            groupId = 'my-gradle-test'
            artifactId = 'master'
            version = '5.1.7'
            from components.java
        }
    }
    repositories {
        maven {
            url 'https://apg-772345236255.d.codeartifact.us-east-1.amazonaws.com/maven/APG_Artifact_Repo_lizhiyua/'
            credentials {
                username "aws"
                password System.env.CODEARTIFACT_AUTH_TOKEN
            }
        }
    }
}

``` 
Commit the change to trigger the pipeline.

```shell
git init
git add .
git remote add origin {codecommit_clone_url}
git-defender --setup
git commit -m "init"
git push origin master
```

At this point you are all good to go! You can build you own solution based on this POC.

At this point you will be able to replicate the issue that the envrinoment vairoable is not set and propagated. A quick band-aid workaround is to modify the `buildspec` file as below:

```
post_build:
    commands:
      - |
        $env:CODEARTIFACT_AUTH_TOKEN = aws codeartifact get-authorization-token --domain apg --domain-owner 772345236255 --query authorizationToken --output text
        echo publish into CodeArtifact...
        ./gradlew publish
```

