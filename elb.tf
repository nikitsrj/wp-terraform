resource "aws_elb" "wp-elb" {
  depends_on         = ["aws_instance.wp-server-1b"]
  name               = "wp-elb"
  subnets            = ["${aws_subnet.Public_subnet1_eu_west_1a.id}", "${aws_subnet.Public_subnet2_eu_west_1b.id}", "${aws_subnet.Public_subnet3_eu_west_1c.id}"]
  security_groups    = ["${aws_security_group.wordpress-sg.id}"]
 
  listener {
    instance_port     = 80
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }
  instances                   = ["${aws_instance.wp-server-1b.id}", "${aws_instance.wp-server-1c.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 300
  connection_draining         = true
  connection_draining_timeout = 300

  tags {
    Name = "wp-elb"
  }
}

output "elbdns" {
  value  = "${aws_elb.wp-elb.dns_name}"
}