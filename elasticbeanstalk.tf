
resource "aws_iam_role" "beanstalkgogs" {
    name = "beanstalkgogs"

    managed_policy_arns = [
        "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier",
        "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker",
        "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier",
        "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    ]

    assume_role_policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = "sts:AssumeRole",
          Effect = "Allow",
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        }
      ]
   })
}
resource "aws_iam_instance_profile" "beanstalkgogs_profile" {
    name = "beanstalkgogs-profile"
    role = aws_iam_role.beanstalkgogs.name
}


resource "aws_elastic_beanstalk_application" "gogs" {
  name = "GogsApp"
}
# CREATE ENVIRONMENT
resource "aws_elastic_beanstalk_environment" "gogs-env" {
  name        = "GogsEnvironment"
  application = aws_elastic_beanstalk_application.gogs.name
  solution_stack_name = "64bit Amazon Linux 2 v3.8.0 running Go 1"
  wait_for_ready_timeout = "20m"
  tier = "WebServer"
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.myvpc.id
  }
   setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = aws_subnet.PublicSubnet.id
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = aws_subnet.PrivateAppSubnet.id
  }
  
  # Associate the security group with the Elastic Beanstalk environment
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "SecurityGroups"
    value = aws_security_group.gogs-prod.id
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalkgogs_profile.name
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     =  "True"
  }
  
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.micro"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_USERNAME"
    value = aws_db_instance.rds-gogs-prod.username
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_PASSWORD"
    value = aws_db_instance.rds-gogs-prod.password
  }
  
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_HOSTNAME"
    value = aws_db_instance.rds-gogs-prod.endpoint
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name = "RDS_DB_NAME"
    value = aws_db_instance.rds-gogs-prod.db_name
  }
}