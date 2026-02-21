resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = "hackathon-repo-${var.environment}"
  description   = "Docker repo for hackathon (${var.environment})"
  format        = "DOCKER"
  project       = var.project_id
  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
