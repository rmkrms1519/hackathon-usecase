terraform {
  required_version = ">= 1.14"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.20.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "vpc" {
  source      = "./modules/vpc"
  project_id  = var.project_id
  region      = var.region
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

module "iam" {
  source      = "./modules/iam"
  project_id  = var.project_id
  environment = var.environment
}

module "gcr" {
  source      = "./modules/gcr"
  project_id  = var.project_id
  region      = var.region
  environment = var.environment
}

module "gke" {
  source              = "./modules/gke"
  project_id          = var.project_id
  region              = var.region
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_subnet_id   = module.vpc.private_subnet_id
  gke_service_account = module.iam.gke_service_account_email
  depends_on          = [module.vpc, module.iam]
}
