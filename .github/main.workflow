workflow "Build and Push" {
  on = "push"
  resolves = ["Push image to GCR"]
}

action "Build Docker image" {
  uses = "actions/docker/cli@master"
  args = ["build", "-t", "gcbapp-dockerfile-example", "."]
}

action "Deploy branch filter" {
  needs = ["Set Credential Helper for Docker"]
  uses = "actions/bin/filter@master"
  args = "branch master"
}

action "Setup Google Cloud" {
  uses = "actions/gcloud/auth@master"
  secrets = ["GCLOUD_AUTH"]
}

action "Tag image for GCR" {
  needs = ["Setup Google Cloud", "Build Docker image"]
  uses = "actions/docker/tag@master"
  env = {
    PROJECT_ID = "durable-firefly-245013"
    APPLICATION_NAME = "gcbapp-dockerfile-example"
  }
  args = ["gcbapp-dockerfile-example", "gcr.io/$PROJECT_ID/$APPLICATION_NAME"]
}

action "Set Credential Helper for Docker" {
  needs = ["Setup Google Cloud", "Tag image for GCR"]
  uses = "actions/gcloud/cli@master"
  args = ["auth", "configure-docker", "--quiet"]
}

action "Push image to GCR" {
  needs = ["Setup Google Cloud", "Deploy branch filter"]
  uses = "actions/gcloud/cli@master"
  runs = "sh -c"
  env = {
    PROJECT_ID = "durable-firefly-245013"
    APPLICATION_NAME = "gcbapp-dockerfile-example"
  }
  args = ["docker push gcr.io/$PROJECT_ID/$APPLICATION_NAME"]
}
