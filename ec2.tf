# The EC2 instance that runs Rancher
resource "aws_instance" "rancher" {
  ami                     = "${var.rancher_ami}"
  instance_type           = "${var.instance_type}"
  monitoring              = false
  subnet_id               = "${element(var.subnet_private_list, 0)}"
  vpc_security_group_ids  = ["${list(var.sg_rds_access, aws_security_group.rancher-instance.id)}"]
  source_dest_check       = true
  user_data               = "${data.template_file.user_data.rendered}"

  root_block_device {
    volume_type = "standard"
    volume_size =  "${var.instance_size}"
    delete_on_termination = true
  }

  tags {
    Name = "${var.environment}-rancher"
    Env = "${var.environment}"
    Terraform           = "true"
  }
}

output "ec2-instance-id"   { value = "${aws_instance.rancher.id}" }
output "ec2-instance-private-ip"   { value = "${aws_instance.rancher.private_ip}" }
output "ec2-rancher-private-dns" {value = "${aws_instance.rancher.private_dns}"}




