resource "aws_db_subnet_group" "wp-db-subnet" {
  depends_on = ["aws_route_table_association.subnet_eu_west_1c_association"]
  name       = "wp-db-subnet"
  subnet_ids = ["${aws_subnet.Private_subnet_eu_west_1b.id}", "${aws_subnet.Private_subnet_eu_west_1c.id}"]

  tags {
    Name = "wp-db-subnet"
  }
}

resource "aws_security_group" "db-sg" {
  depends_on      = ["aws_instance.wp-server-1c"]
  name            = "db-sg"
  vpc_id          = "${aws_vpc.vpc_tuto.id}"
  
  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["${aws_instance.wp-server-1b.private_ip}/32"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["${aws_instance.wp-server-1c.private_ip}/32"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
 tags {
    Name = "db-sg"
  }
}

resource "aws_db_instance" "wp-db" {
  depends_on           = ["aws_db_subnet_group.wp-db-subnet"]
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  identifier           = "wp-db"
  name                 = "wpdb"
  username             = "wpadmin"
  password             = "wpadmin123"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = "true"
  vpc_security_group_ids  =  ["${aws_security_group.db-sg.id}"]
  db_subnet_group_name    =  "${aws_db_subnet_group.wp-db-subnet.name}"
}

output "endpoint" {
  value = "${aws_db_instance.wp-db.address}"
}