data "template_file" "user_data" {

  template = "${file(var.userdata_path)}"

  vars {
    authorized_keys   =  "  - ${join("\n  - ", split("\n", trimspace(file(var.authorized_keys))))}"
    docker_version    = "${var.docker_version}"
    rancher_version   = "${var.rancher_version}"
    rds_host          = "${var.rds_host}"
    rds_user          = "${var.rds_user}"
    rds_password      = "${var.rds_password}"
    rds_dbname        = "${var.rds_dbname}"
    rancher_address   = "rancher.${var.environment}.localnet"
  }
}