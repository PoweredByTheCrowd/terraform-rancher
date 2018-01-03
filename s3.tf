# The S3 bucket where the logging of the external Load Balancer is written to
resource "aws_s3_bucket" "logging_bucket" {

  bucket = "${var.bucket_prefix}-${var.environment}"
  acl = "private"
  force_destroy = true

  tags {
    Name = "${var.bucket_prefix}-${var.environment}"
    ManagedBy = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}
