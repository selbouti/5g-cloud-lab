output "vm1_srsran_public_ip" {
  value = oci_core_instance.vm1_srsran.public_ip
}

output "vm2_core5g_public_ip" {
  value = oci_core_instance.vm2_core5g.public_ip
}

output "vm3_kamailio_public_ip" {
  value = oci_core_instance.vm3_kamailio.public_ip
}
