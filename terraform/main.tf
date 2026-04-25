terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  credentials = var.credentials
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

resource "google_compute_network" "lab_vpc" {
  name                    = "lab-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_radio" {
  name          = "subnet-radio"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.lab_vpc.id
  region        = var.region
}

resource "google_compute_subnetwork" "subnet_core" {
  name          = "subnet-core"
  ip_cidr_range = "10.0.2.0/24"
  network       = google_compute_network.lab_vpc.id
  region        = var.region
}

resource "google_compute_subnetwork" "subnet_op" {
  name          = "subnet-op"
  ip_cidr_range = "10.0.3.0/24"
  network       = google_compute_network.lab_vpc.id
  region        = var.region
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.lab_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.lab_vpc.name

  allow {
    protocol = "all"
  }

  source_ranges = ["10.0.0.0/16"]
}

resource "google_compute_instance" "vm1_srsran" {
  name         = "vm-srsran"
  machine_type = "e2-standard-2"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 50
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_radio.id
    network_ip = "10.0.1.10"
    access_config {}
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

resource "google_compute_instance" "vm2_core5g" {
  name         = "vm-core-5g"
  machine_type = "e2-standard-2"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 50
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_core.id
    network_ip = "10.0.2.10"
    access_config {}
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}

resource "google_compute_instance" "vm3_kamailio" {
  name         = "vm-kamailio"
  machine_type = "e2-standard-2"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 50
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet_op.id
    network_ip = "10.0.3.10"
    access_config {}
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}
resource "google_compute_firewall" "allow_swarm" {
  name    = "allow-swarm"
  network = google_compute_network.lab_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["2377", "7946"]
  }

  allow {
    protocol = "udp"
    ports    = ["7946", "4789"]
  }

  source_ranges = ["10.0.0.0/16"]
}