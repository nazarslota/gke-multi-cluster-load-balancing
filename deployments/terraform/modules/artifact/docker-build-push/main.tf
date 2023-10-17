# modules/docker-build-push/main.tf

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
    command = <<EOL
      cd ../../

      docker login -u _json_key --password-stdin https://${google_artifact_registry_repository.default.location}-docker.pkg.dev < $GOOGLE_APPLICATION_CREDENTIALS

      docker build \
        --file deployments/docker/Dockerfile \
        --tag "${google_artifact_registry_repository.default.location}-docker.pkg.dev/${var.project}/${var.repository}/${var.application}:${var.build_number}" \
        --tag "${google_artifact_registry_repository.default.location}-docker.pkg.dev/${var.project}/${var.repository}/${var.application}:latest" \
        .

      docker push "${google_artifact_registry_repository.default.location}-docker.pkg.dev/${var.project}/${var.repository}/${var.application}:${var.build_number}"
      docker push "${google_artifact_registry_repository.default.location}-docker.pkg.dev/${var.project}/${var.repository}/${var.application}:latest"
    EOL
  }

  depends_on = [
    google_artifact_registry_repository.default
  ]
}

