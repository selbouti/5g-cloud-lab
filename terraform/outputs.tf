output "vm1_srsran_public_ip" {
  value = google_compute_instance.vm1_srsran.network_interface[0].access_config[0].nat_ip
}

output "vm2_core5g_public_ip" {
  value = google_compute_instance.vm2_core5g.network_interface[0].access_config[0].nat_ip
}

output "vm3_kamailio_public_ip" {
  value = google_compute_instance.vm3_kamailio.network_interface[0].access_config[0].nat_ip
}
