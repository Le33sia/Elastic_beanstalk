#security groups
resource "aws_security_group" "rds-gogs-prod" {
  vpc_id = aws_vpc.myvpc.id
  name = "rds-gogs-prod"
  description = "Allow inbound mysql traffic"
}
resource "aws_security_group_rule" "allow-mysql" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_group_id = "${aws_security_group.rds-gogs-prod.id}"
    source_security_group_id = "${aws_security_group.gogs-prod.id}"
}
resource "aws_security_group_rule" "allow-outgoing" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_group_id = "${aws_security_group.rds-gogs-prod.id}"
    cidr_blocks = ["0.0.0.0/0"]
}


# rds
resource "aws_db_instance" "rds-gogs-prod" {
  allocated_storage    = 10
  
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  identifier           = "gogs-prod"
  db_name              = "mydb"
  username             = "root"
  password             = "MYSQLROOTPASS"
  db_subnet_group_name = aws_db_subnet_group.rds-gogs-prod.name
  parameter_group_name = "default.mysql5.7"
  multi_az             = "false"
  vpc_security_group_ids = [aws_security_group.rds-gogs-prod.id]
  storage_type         = "gp2"
  skip_final_snapshot  = true
}

resource "aws_db_subnet_group" "rds-gogs-prod" {
    name = "rds-gogs-prod"
    description = "RDS subnet group"
    subnet_ids = [aws_subnet.PrivateDbSubnet.id, aws_subnet.PrivateAppSubnet.id, aws_subnet.PrivateAppSubnet2.id]
} 
