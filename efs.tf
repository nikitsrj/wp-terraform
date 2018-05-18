
resource "aws_security_group" "efs-sg" {
  depends_on      = ["aws_instance.bastion"]
  name            = "efs-sg"
  vpc_id          = "${aws_vpc.vpc_tuto.id}"
  
  ingress {
    protocol    = "tcp" 
    from_port   = 2049
    to_port     = 2049
    cidr_blocks = ["${aws_instance.wp-server-1b.private_ip}/32"]
  }
  ingress {
    protocol    = "tcp" 
    from_port   = 2049
    to_port     = 2049
    cidr_blocks = ["${aws_instance.wp-server-1c.private_ip}/32"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
 tags {
    Name = "efs-sg"
  }
}

resource "aws_efs_file_system" "wp-efs" {
  depends_on = ["aws_security_group.efs-sg"]
  tags {
    Name = "wp-efs"
  }
}

resource "aws_efs_mount_target" "wp-efs-mtarget0" {
  depends_on       = ["aws_efs_file_system.wp-efs"]
  file_system_id   = "${aws_efs_file_system.wp-efs.id}"
  subnet_id        = "${aws_subnet.Private_subnet_eu_west_1b.id}"
  security_groups  = ["${aws_security_group.efs-sg.id}"]
}

resource "aws_efs_mount_target" "wp-efs-mtarget1" {
  depends_on       = ["aws_efs_file_system.wp-efs"]
  file_system_id   = "${aws_efs_file_system.wp-efs.id}"
  subnet_id        = "${aws_subnet.Private_subnet_eu_west_1c.id}"
  security_groups  = ["${aws_security_group.efs-sg.id}"]
}
