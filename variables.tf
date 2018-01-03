variable "environment" { default = "rancher" }

# The id of the VPC where the EC2 instance is launched
variable "vpc_id"                   {}
# The Route 53 zone where the route to the EC2 instance can be registered in
variable "r53_zone_id"              {}
# The certificate ARN that corresponds with the Route 53 domain (either ACM/IAM)
variable "certificate_arn"          {}

# The AMI of the EC2 instance, must be RancherOS
variable "rancher_ami"              {} #RancherOS
# The instance type
variable "instance_type"            { default = "t2.medium" }
# The size of the EBS used by the instance
variable "instance_size"            { default =  "30" }

# A security group that allows a connection to the RDS cluster/instance.
# The EC2 instance is added to this security group
variable "sg_rds_access"            {}
# The hostname of the RDS cluster/instance
variable "rds_host"                 {}
# The user name that can be used to connect to the RDS cluster/instance
variable "rds_user"                 {}
# The password that can be used to connect to the RDS instance
# Do not provide a default value, instead enter it when executing terraform plan
variable "rds_password"             {}
# The name of the database for Rancher
variable "rds_dbname"               {}

# The subnets where the instance can be placed in, the first of the list is taken
# You can use this to create a HA Rancher setup
variable "subnet_private_list" {
  type = "list"
  default = []
}

# The cidr blocks which are allowed to connect to the Load balancer
variable "allowed_cidr_blocks" {
  type = "list"
  default = ["0.0.0.0/0"]
}

# The cidr block of the bastion host, this restricts connnecting through ssh
variable "bastion_cidr_blocks" {
  type = "list"
  default = ["0.0.0.0/0"]
}
# The public subnets that are to be associated with by the Load Balancer (at least two)
variable "subnet_public_list"       {
  type    = "list"
  default = []
}

# Path to the user data for the EC2 instance
variable "userdata_path"            { default = "./userdata/rancher.yml" }

variable "authorized_keys"          { default = "./authorized_keys/authorized_keys" }
variable "bucket_prefix"            { default = "https-external" }
variable "docker_version"           { default = "docker-17.03.1-ce" }
variable "rancher_version"          { default = "stable" }

/*
  The identifier below is specifically for us-east-1!
  See the list below for other regions, source: http://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions

  us-east-1	US East (N. Virginia)	127311923021
  us-east-2	US East (Ohio)	033677994240
  us-west-1	US West (N. California)	027434742980
  us-west-2	US West (Oregon)	797873946194
  ca-central-1	Canada (Central)	985666609251
  eu-west-1	EU (Ireland)	156460612806
  eu-central-1	EU (Frankfurt)	054676820928
  eu-west-2	EU (London)	652711504416
  ap-northeast-1	Asia Pacific (Tokyo)	582318560864
  ap-northeast-2	Asia Pacific (Seoul)	600734575887
  ap-southeast-1	Asia Pacific (Singapore)	114774131450
  ap-southeast-2	Asia Pacific (Sydney)	783225319266
  ap-south-1	Asia Pacific (Mumbai)	718504428378
  sa-east-1	South America (São Paulo)	507241528517

*/
variable "elb_identifiers"           {
  type    = "list"
  default = ["127311923021"]
}

# Do not alter these values
data "aws_vpc" "default_vpc"        { id = "${var.vpc_id}" }
data "aws_route53_zone" "zone"  { zone_id = "${var.r53_zone_id}" }



