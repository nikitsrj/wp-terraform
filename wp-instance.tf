

resource "aws_key_pair" "bastion_key" {
  key_name   = "wp-bastion"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFpdZV0ICwbphZjqT2fJwEHPTObWTkEad5HdLgtnhNUFI0Nj6tY59BdaG0WCX2VLD+hpN2Xyg2zQCuQiesk2huZ6gDbQPFAChRZ/e54V5QNE4NEyZvcJcetNAbdJRGvci0imOAS+YdQc/h9StG+MQ9uIEDAiYcXrHC+xz4NFU3L/8l48ybz4uI9iGP19/4pficDjr1re45BQEjC0+QyQ7KlvylNBU+EmG4uMh/z/EWnVCL8VjnGflRjAusvJTx7RxpJuWLhHGcyuEJC1eAh/OntT/qvOBioir7GyNTMq0NWXhFGCVJ3C/4/RvItQY0cvi9AQeuGs/dEe0RhCEjKf9Z root@nikit-Ubuntu"
}

resource "aws_security_group" "wordpress-sg" {
  depends_on      = ["aws_route_table_association.subnet_eu_west_1c_association"]
  name            = "wp-sg"
  vpc_id          = "${aws_vpc.vpc_tuto.id}"
  
  ingress {
    protocol    = "tcp" 
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
 tags {
    Name = "wordpress-sg"
  }
}

resource "aws_instance" "wp-server-1b" {
  depends_on                  = ["aws_security_group.wordpress-sg"]
  ami                         = "ami-9cbe9be5"
  key_name                    = "${aws_key_pair.bastion_key.key_name}"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = ["${aws_security_group.wordpress-sg.id}"]
  subnet_id                   = "${aws_subnet.Private_subnet_eu_west_1b.id}"
  tags {
    Name = "WP-Server1"
  }
}

resource "aws_instance" "wp-server-1c" {
  depends_on                  = ["aws_security_group.wordpress-sg"]
  ami                         = "ami-9cbe9be5"
  key_name                    = "${aws_key_pair.bastion_key.key_name}"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = ["${aws_security_group.wordpress-sg.id}"]
  subnet_id                   = "${aws_subnet.Private_subnet_eu_west_1c.id}"
  tags {
    Name = "WP-Server2"
  }
}