resource "aws_route53_record" "rancher_server_external" {
  zone_id = "${var.r53_zone_id}"
  name    = "rancher.${data.aws_route53_zone.zone.name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_alb.rancher.dns_name}"]
}

resource "aws_route53_zone" "internal" {
  name      = "${var.environment}.localnet"
  vpc_id    = "${data.aws_vpc.default_vpc.id}"

  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_route53_record" "rancher-server-internal" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "rancher.${var.environment}.localnet"
  type    = "CNAME"
  ttl     = "300"

  records = ["${aws_alb.alb-internal.dns_name }"]
}

output "rancher_url" { value = "${aws_route53_record.rancher_server_external.name}"}
output "rancher_internal_url" { value = "${aws_route53_record.rancher-server-internal.name}"}