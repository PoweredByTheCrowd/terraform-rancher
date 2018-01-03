# The Load balancer that forwards traffic to the EC2 instance that runs Rancher
resource "aws_alb" "rancher" {
  depends_on = ["aws_s3_bucket_policy.s3-logging-bucket-policy"]

  name = "${var.environment}-alb"
  internal = false
  idle_timeout = 60

  subnets = [
    "${var.subnet_public_list}"
  ]

  security_groups = [
    "${aws_security_group.rancher-alb.id}"]

  access_logs {
    bucket = "${aws_s3_bucket.logging_bucket.id}"
    prefix = "${var.environment}-alb"
  }

  tags {
    Name = "${var.environment}-rancher-alb",
    Env = "${var.environment}"
  }
}

# An internal Load balancer that can be used by Rancher hosts to connect to the Rancher server
resource "aws_alb" "alb-internal" {

  name = "${var.environment}-alb-internal"
  internal = true
  idle_timeout = 60

  subnets = [
    "${var.subnet_private_list}"
  ]
  security_groups = [
    "${aws_security_group.rancher-alb-internal.id}"
  ]

  tags {
    Name = "${var.environment}-alb-internal",
    Env = "${var.environment}"
  }
}

# The target group for external traffic to rancher
resource "aws_alb_target_group" "rancher-ext-target-group" {
  name     = "${var.environment}-rancher-ext"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.default_vpc.id}"

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 2
    timeout = 5
    path = "/ping"
    interval = 10
  }
}

# The target group for internal traffic to rancher
resource "aws_alb_target_group" "rancher-server-internal-tg" {
  name     = "${var.environment}-rancher-svr-internal"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.default_vpc.id}"

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 2
    timeout = 5
    path = "/ping"
    interval = 10
  }
}

# The target group for internal traffic to rancher
resource "aws_alb_target_group" "rancher-host-internal-tg" {
  name     = "${var.environment}-rancher-hst-internal"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.default_vpc.id}"

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 2
    timeout = 5
    path = "/ping"
    interval = 10
  }
}

# Forwards all https traffic to port 81 of instances in this group
# Put Rancher hosts in this target group to allow external traffic to reach your services
resource "aws_alb_target_group" "default-https-tg" {
  name     = "${var.environment}-default-https"
  port     = 81
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.default_vpc.id}"

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 2
    timeout = 5
    path = "/healthcheck"
    interval = 10
  }
}

# Forwards all http traffic to port 81 of instances in this group
# Put Rancher hosts in this target group to allow external traffic to reach your services
resource "aws_alb_target_group" "default-http-tg" {
  name     = "${var.environment}-default-http"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.default_vpc.id}"

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 2
    timeout = 5
    path = "/healthcheck"
    interval = 10
  }
}

// this is the default https listener of the load balancer,
resource "aws_alb_listener" "rancher-https-listener" {
  load_balancer_arn = "${aws_alb.rancher.arn}"
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.default-https-tg.arn}"
    type = "forward"
  }
}

// this is the default http listener of the load balancer,
resource "aws_alb_listener" "rancher-http-listener" {
  load_balancer_arn = "${aws_alb.rancher.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.default-http-tg.arn}"
    type = "forward"
  }
}

// this is the internal listener of the load balancer, by default we direct to rancher hosts
resource "aws_alb_listener" "rancher-internal-listener" {
  load_balancer_arn = "${aws_alb.alb-internal.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.rancher-host-internal-tg.arn}"
    type = "forward"
  }
}

//resource "aws_alb_listener" "rancher-server-internal-listener" {
//  load_balancer_arn = "${aws_alb.alb-internal.arn}"
//  port = "8080"
//  protocol = "HTTP"
//
//  default_action {
//    target_group_arn = "${aws_alb_target_group.rancher-server-internal-tg.arn}"
//    type = "forward"
//  }
//}

# Attaches the EC2 instance that runs Rancher to the external Load balancer
resource "aws_alb_target_group_attachment" "rancher-external-tga" {
  target_group_arn = "${aws_alb_target_group.rancher-ext-target-group.arn}"
  target_id = "${aws_instance.rancher.id}"
  port = 8080
}


# Attaches the EC2 instance that runs Rancher to the external Load balancer
resource "aws_alb_target_group_attachment" "rancher-server-internal-tga" {
  target_group_arn = "${aws_alb_target_group.rancher-server-internal-tg.arn}"
  target_id = "${aws_instance.rancher.id}"
  port = 8080
}


// this rule is used to external forward traffic to the rancher host
resource "aws_alb_listener_rule" "rancher_host_forward" {
  listener_arn = "${aws_alb_listener.rancher-https-listener.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.rancher-ext-target-group.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.rancher_server_external.name}"]
  }
}

// this rule is used to forward internal traffic to the rancher host
resource "aws_alb_listener_rule" "rancher_internal_server_forward" {
  listener_arn = "${aws_alb_listener.rancher-internal-listener.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.rancher-server-internal-tg.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.rancher-server-internal.name}"]
  }
}

output "http_target_group_arn" {value = "${aws_alb_target_group.default-http-tg.arn}"}
output "https_target_group_arn" {value = "${aws_alb_target_group.default-https-tg.arn}"}
output "http_internal_target_group_arn" {value = "${aws_alb_target_group.rancher-host-internal-tg.arn}"}

