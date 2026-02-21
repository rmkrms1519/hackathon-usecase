resource "google_compute_network" "vpc" {
  name                    = "hackathon-vpc-${var.environment}"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "public_subnet_1" {
  name          = "public-subnet-1-${var.environment}"
  ip_cidr_range = cidrsubnet(var.vpc_cidr, 8, 1)
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "public_subnet_2" {
  name          = "public-subnet-2-${var.environment}"
  ip_cidr_range = cidrsubnet(var.vpc_cidr, 8, 2)
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "private_subnet" {
  name                     = "private-subnet-${var.environment}"
  ip_cidr_range            = cidrsubnet(var.vpc_cidr, 8, 10)
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "gke-pods-${var.environment}"
    ip_cidr_range = cidrsubnet(var.vpc_cidr, 4, 1)
  }
  secondary_ip_range {
    range_name    = "gke-services-${var.environment}"
    ip_cidr_range = cidrsubnet(var.vpc_cidr, 8, 20)
  }
}

resource "google_compute_router" "router" {
  name    = "hackathon-router-${var.environment}"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "hackathon-nat-${var.environment}"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal-${var.environment}"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = [var.vpc_cidr]
}

resource "google_compute_firewall" "allow_health_checks" {
  name    = "allow-health-checks-${var.environment}"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
  }
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
}
