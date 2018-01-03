# The policy document that allows to write the logging
data "aws_iam_policy_document" "s3-logging-bucket-policy-document" {
  statement {
    actions = [
      "s3:PutObject"
    ]

    principals {
      type        = "AWS"
      identifiers = "${var.elb_identifiers}"
    }

    resources = [
      "${aws_s3_bucket.logging_bucket.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "s3-logging-bucket-policy" {
  bucket = "${aws_s3_bucket.logging_bucket.id}"
  policy = "${data.aws_iam_policy_document.s3-logging-bucket-policy-document.json}"
}
