# terraform-rancher

This a terraform module to set up an EC2 instance on Amazon Web Services (AWS) and starts Rancher server. Terraform is a powerful tool which allows you to 
maintain your infrastructure in code completely. You can set up your Rancher instance and maintain your network in minutes. 
No need to click around in the console. To learn more about Terraform click [here](https://www.terraform.io/intro/index.html).
 
## Features
- Creates a EC2 instance and starts Rancher server
- Creates an external load balancer that forwards traffic to the EC2 instance
- Creates a url for your Rancher server
- Creates an internal load balancer which Rancher hosts can use to connect to the Rancher server
- Logs all requests to the external load balancer to S3

## Requirements
- Terraform CLI (v0.9.11)
- AWS account
- A VPC in which the instance is to be created
- A database for the Rancher server
- A domain registered in [Route 53](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-register.html)
- A SSL/TLS certificate that corresponds with the domain, either in
[ACM](http://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request.html) or
[IAM](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_server-certs.html#upload-server-certificate)

## Usage
Create a terraform [configuration](https://www.terraform.io/intro/getting-started/build.html#configuration) and include 
the following:

    module "rancher" {
      source              = "githuburl"
      environment         = "${var.environment}"
      vpc_id              = "${var.vpc_id}"
      r53_zone_id         = "${var.r53_zone_id}"
      certificate_arn     = "${var.certificate_arn}"
      rancher_ami         = "${var.rancher_ami}"
      sg_rds_access       = "${var.sg_rds_access}"
      rds_host            = "${var.rds_cluster_endpoint}"
      rds_user            = "${var.rds_user}"
      rds_dbname          = "${var.rds_dbname}"
      rds_password        = "${var.rds_password}"
      subnet_private_list = "${var.private_subnet_list}"
      subnet_public_list  = "${var.public_subnet_list}"
      userdata_path       = "${var.rancher_userdata_path}"
      elb_identifiers     = "${var.elb_identifiers}"
    }

Apply your Terraform configuration. 

## Notes


