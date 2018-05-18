resource "aws_security_group" "bastion-sg" {
  depends_on      = ["aws_instance.wp-server-1c"]
  name            = "bastion-security-group"
  vpc_id          = "${aws_vpc.vpc_tuto.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
 tags {
    Name = "bastion-security-group"
  }
}

resource "aws_instance" "bastion" {
  depends_on                  = ["aws_security_group.bastion-sg"]
  ami                         = "ami-9cbe9be5"
  key_name                    = "${aws_key_pair.bastion_key.key_name}"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.bastion-sg.id}"]
  subnet_id                   = "${aws_subnet.Public_subnet1_eu_west_1a.id}"
  associate_public_ip_address = true
  tags {
    Name = "bastion"
  }
}

output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}


resource "aws_security_group_rule" "modify-wp-sg" {
  depends_on      = ["aws_instance.bastion"]
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["${aws_instance.bastion.private_ip}/32"]
  security_group_id = "${aws_security_group.wordpress-sg.id}"
}