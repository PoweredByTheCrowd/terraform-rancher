# The security group for the Rancher instance
# It allows traffic associated with Rancher
# It allows ssh connections form anywhere (you should restrict this)
resource "aws_security_group" "rancher-instance" {
  name        = "${var.environment}-secgroup-rancher"
  description = "instance default security group"
  vpc_id      = "${data.aws_vpc.default_vpc.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.bastion_cidr_blocks}"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.rancher-alb.id}",
      "${aws_security_group.rancher-alb-internal.id}",
      "${aws_security_group.rancher-machine.id}",
    ]
  }

  ingress {
    from_port = 9345
    to_port = 9345
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.rancher-alb.id}",
      "${aws_security_group.rancher-alb-internal.id}",
      "${aws_security_group.rancher-machine.id}",
    ]
  }

  ingress {
    from_port = 18080
    to_port = 18080
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.rancher-alb.id}",
      "${aws_security_group.rancher-alb-internal.id}",
      "${aws_security_group.rancher-machine.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name            = "${var.environment}-rancher-instance"
    Environment     = "${var.environment}"
    Terraform       = "True"
  }
}


# The security group that can be used by Rancher hosts
resource "aws_security_group" "rancher-machine" {
  name        = "${var.environment}-sg-rancher-machine"
  description = "rancher machine security group"
  vpc_id      = "${data.aws_vpc.default_vpc.id}"

  ingress {
    from_port = 500
    to_port = 500
    protocol = "udp"
    cidr_blocks = ["${data.aws_vpc.default_vpc.cidr_block}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.bastion_cidr_blocks}"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.rancher-alb.id}",
      "${aws_security_group.rancher-alb-internal.id}"
    ]
  }

  ingress {
    from_port = 81
    to_port = 81
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.rancher-alb.id}",
      "${aws_security_group.rancher-alb-internal.id}"
    ]
  }

  ingress {
    from_port = 4500
    to_port = 4500
    protocol = "udp"
    cidr_blocks = ["${data.aws_vpc.default_vpc.cidr_block}"]
  }

  ingress {
    from_port = 9200
    to_port = 9200
    protocol = "tcp"
    cidr_blocks = ["${data.aws_vpc.default_vpc.cidr_block}"]
  }

  ingress {
    from_port = 9090
    to_port = 9090
    protocol = "tcp"
    cidr_blocks = ["${data.aws_vpc.default_vpc.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name            = "${var.environment}-rancher-machine"
    Environment     = "${var.environment}"
    Terraform       = "True"
  }
}

# The security group for your Load balancer
# You should alter the allowed cidr blocks to your own ip-address(es)
resource "aws_security_group" "rancher-alb" {
  name        = "${var.environment}-secgroup-alb"
  description = "alb default security group"
  vpc_id      = "${data.aws_vpc.default_vpc.id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_cidr_blocks}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_cidr_blocks}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.allowed_cidr_blocks}"]
  }

  tags {
    Name            = "${var.environment}-rancher-alb"
    Environment     = "${var.environment}"
    Terraform       = "True"
  }
}

# The security groups for the internal load balancer
resource "aws_security_group" "rancher-alb-internal" {
  name        = "${var.environment}-alb-internal"
  description = "elb internal security group"
  vpc_id      = "${data.aws_vpc.default_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.default_vpc.cidr_block}"]
  }
  // used for elastic search
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.default_vpc.cidr_block}"]
  }

  // used for prometheus between rancher hosts
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.default_vpc.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name            = "${var.environment}-rancher-alb"
    Environment     = "${var.environment}"
    Terraform       = "True"
  }
}



output "rancher-sg" { value = "${aws_security_group.rancher-instance.id}" }
output "rancher-machine-sg" { value = "${aws_security_group.rancher-machine.id}" }

