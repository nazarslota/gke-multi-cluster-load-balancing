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
    command = <<EOL
      cd ../../

      rm -f account.json
      echo "${var.service_account_key_base64}" >> account.json

      docker login \
        -u _json_key_base64 \
        --password-stdin https://${google_artifact_registry_repository.default.location}-docker.pkg.dev < account.json

      docker build \
        --platform linux/amd64 \
        --file deployments/docker/Dockerfile \
        --tag "${google_artifact_registry_repository.default.location}-docker.pkg.dev/${var.project}/${var.repository}/${var.app}:${var.build_number}" \
        --tag "${google_artifact_registry_repository.default.location}-docker.pkg.dev/${var.project}/${var.repository}/${var.app}:latest" \
        .

      docker push "${google_artifact_registry_repository.default.location}-docker.pkg.dev/${var.project}/${var.repository}/${var.app}:${var.build_number}"
      docker push "${google_artifact_registry_repository.default.location}-docker.pkg.dev/${var.project}/${var.repository}/${var.app}:latest"

      rm -f account.json
    EOL
  }

  depends_on = [
    google_artifact_registry_repository.default
  ]
}
