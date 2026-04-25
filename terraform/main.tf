terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

provider "oci" {
  user_ocid    = var.user_ocid
  tenancy_ocid = var.tenancy_ocid
  fingerprint  = var.fingerprint
  region       = var.region
  private_key  = var.private_key
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# VCN principal
resource "oci_core_vcn" "lab_vcn" {
  compartment_id = var.tenancy_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "5g-lab-vcn"
}

# Internet Gateway
resource "oci_core_internet_gateway" "lab_igw" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.lab_vcn.id
  display_name   = "5g-lab-igw"
}

# Route Table
resource "oci_core_route_table" "lab_rt" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.lab_vcn.id
  display_name   = "5g-lab-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.lab_igw.id
  }
}

# Security List
resource "oci_core_security_list" "lab_sl" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.lab_vcn.id
  display_name   = "5g-lab-sl"

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "all"
    source   = "10.0.0.0/8"
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

# Subnet Radio Access
resource "oci_core_subnet" "subnet_radio" {
  compartment_id    = var.tenancy_ocid
  vcn_id            = oci_core_vcn.lab_vcn.id
  cidr_block        = "10.0.1.0/24"
  display_name      = "subnet-radio"
  route_table_id    = oci_core_route_table.lab_rt.id
  security_list_ids = [oci_core_security_list.lab_sl.id]
}

# Subnet Core 5G
resource "oci_core_subnet" "subnet_core" {
  compartment_id    = var.tenancy_ocid
  vcn_id            = oci_core_vcn.lab_vcn.id
  cidr_block        = "10.0.2.0/24"
  display_name      = "subnet-core-5g"
  route_table_id    = oci_core_route_table.lab_rt.id
  security_list_ids = [oci_core_security_list.lab_sl.id]
}

# Subnet Operateur
resource "oci_core_subnet" "subnet_op" {
  compartment_id    = var.tenancy_ocid
  vcn_id            = oci_core_vcn.lab_vcn.id
  cidr_block        = "10.0.3.0/24"
  display_name      = "subnet-operateur"
  route_table_id    = oci_core_route_table.lab_rt.id
  security_list_ids = [oci_core_security_list.lab_sl.id]
}

# VM1 - srsRAN (subnet radio)
resource "oci_core_instance" "vm1_srsran" {
  compartment_id      = var.tenancy_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "vm1-srsran"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 2
    memory_in_gbs = 8
  }

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_image_id
  }

  create_vnic_details {
    subnet_id              = oci_core_subnet.subnet_radio.id
    private_ip             = "10.0.1.10"
    assign_public_ip       = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

# VM2 - Core 5G Swarm Manager (subnet core)
resource "oci_core_instance" "vm2_core5g" {
  compartment_id      = var.tenancy_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
  display_name        = "vm2-core-5g"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 2
    memory_in_gbs = 8
  }

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_image_id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet_core.id
    private_ip       = "10.0.2.10"
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

# VM3 - Kamailio Swarm Worker (subnet operateur)
resource "oci_core_instance" "vm3_kamailio" {
  compartment_id      = var.tenancy_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "vm3-kamailio"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 4
  }

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_image_id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet_op.id
    private_ip       = "10.0.3.10"
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}
