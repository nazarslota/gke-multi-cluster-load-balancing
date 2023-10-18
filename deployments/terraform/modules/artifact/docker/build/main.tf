# modules/build/docker/artifact/main.tf

resource "google_artifact_registry_repository" "default" {
  repository_id = var.repository
  location      = var.location
  format        = "DOCKER"

  description = "GKE repository"
}

resource "null_resource" "docker_build_and_push" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    environment = {
      GOOGLE_APPLICATION_CREDENTIALS_CONTENT = var.artifact_service_account_key
    }

    command = <<EOL
      cd ../../
      echo "$GOOGLE_APPLICATION_CREDENTIALS_CONTENT" >> temporary_key.json

      docker login \
        -u _json_key \
        --password-stdin https://${google_artifact_registry_repository.default.location}-docker.pkg.dev < temporary_key.json

      docker build \
        --file deployments/docker/Dockerfile \
        --tag "${google_artifact_registry_repository.default.location}-docker.pkg.dev/${var.project}/${var.repository}/${var.application}:${var.build_number}" \
        --tag "${google_artifact_registry_repository.default.location}-docker.pkg.dev/${var.project}/${var.repository}/${var.application}:latest" \
        .

      docker push "${google_artifact_registry_repository.default.location}-docker.pkg.dev/${var.project}/${var.repository}/${var.application}:${var.build_number}"
      docker push "${google_artifact_registry_repository.default.location}-docker.pkg.dev/${var.project}/${var.repository}/${var.application}:latest"
      rm temporary_key.json
    EOL
  }

  depends_on = [
    google_artifact_registry_repository.default
  ]
}

