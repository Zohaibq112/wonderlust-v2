variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  default     = "ami-0e86e20dae9224db8"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  default     = "10.0.2.0/24"
}

variable "public_key" {
  description = "SSH public key"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCfXOzTmJlfEwkTDqrjm9ivSaraO3dX29u/czhQGhdW/KEc6T6x25ZRSVuZM//nS5rhRLGrwzP9U1MpIBBWgiF1EDmVRpoYxHKdWehkQFl0SRoOkd4ofckV9qASFhU0OLW+CldnTEF7n6K6fHpRMxyujMe+UOFIRSDIpa4PcQhs8GBOt4ALY2N+hTQa8+Huj7d9QhOnK5Rifo9QDpyxk3L6Mpi80oUseq4m0hyKAsYtF6ZOSU8RESgrk2BegS3VhbLCTr8SVc9UlR5qk2GJpCMw1f8lRcU4sFsbWOHye2IXHDPT4+xu3popqZO5f30rX65c25Wqo3CeN44aXcKMSuaGFGHd2b/IR+LLAxbQM2vSHigdMs2BXlbXQEXbCKYwQBDb6ooCtVvM88GUt4/avyjLTxfmwSyKrTnrQXgFGfmy3WY8FatfAd6HpDmQ21pQqYxzRZHzYP9q5mr/Evze7vRacBs8q62/N0HbYrl4+FO6sFBJsqxTM26uEYoEoiYBbISiaiXOLx4qZbzNcSJtBpz9bQMg1NYF2jd/er0e1QmTYZiU+/dOvQKIVO42DyaKO3ZnbhdueD5NTqGtVB3zgsn0XPVm+g5gzQvT+B8nMwpvboUbZt3RWTVFqZLjBYN+q1SJVqdaNfXM6f4BMCBlpxWy5ilBrdHMvEUeEZDoVfkLvQ== hp@DESKTOP-H2P26TK"
}