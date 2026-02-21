terraform {
  backend "gcs" {
    bucket = "hackathon-tf-state-21022026"
    prefix = "terraform/state"
  }
}
