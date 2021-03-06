# The provider here is aws but it can be other provider
provider "aws" {
region = "eu-west-1"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "vpc_tuto" {
  cidr_block = "172.31.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "WP-Test"
  }
}

# Create a way out to the internet
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc_tuto.id}"
  tags {
        Name = "WP-InternetGateway"
    }
}

# Public route as way out to the internet
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vpc_tuto.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}


# Create the private route table
resource "aws_route_table" "private_route_table" {
    vpc_id = "${aws_vpc.vpc_tuto.id}"

    tags {
        Name = "WP-Private route table"
    }
}

# Create private route
resource "aws_route" "private_route" {
	route_table_id  = "${aws_route_table.private_route_table.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.nat.id}"
}



# Create a subnet in the AZ eu-west-1a
resource "aws_subnet" "Public_subnet1_eu_west_1a" {
  vpc_id                  = "${aws_vpc.vpc_tuto.id}"
  cidr_block              = "172.31.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1a"
  tags = {
  	Name =  "Web Subnet az 1a"
  }
}

resource "aws_subnet" "Public_subnet2_eu_west_1b" {
  vpc_id                  = "${aws_vpc.vpc_tuto.id}"
  cidr_block              = "172.31.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1b"
  tags = {
    Name =  "Web Subnet az 1b"
  }
}

resource "aws_subnet" "Public_subnet3_eu_west_1c" {
  vpc_id                  = "${aws_vpc.vpc_tuto.id}"
  cidr_block              = "172.31.3.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1c"
  tags = {
    Name =  "Web Subnet az 1c"
  }
}

# Create a subnet in the AZ eu-west-1b
resource "aws_subnet" "Private_subnet_eu_west_1b" {
  vpc_id                  = "${aws_vpc.vpc_tuto.id}"
  cidr_block              = "172.31.4.0/24"
  availability_zone = "eu-west-1b"
  tags = {
  	Name =  "App Subnet az 1b"
  }
}

# Create a subnet in the AZ eu-west-1c
resource "aws_subnet" "Private_subnet_eu_west_1c" {
  vpc_id                  = "${aws_vpc.vpc_tuto.id}"
  cidr_block              = "172.31.5.0/24"
  availability_zone = "eu-west-1c"
  tags = {
  	Name =  "DB Subnet az 1c"
  }
}

# Create an EIP for the natgateway
resource "aws_eip" "nat" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]
}


# Create a nat gateway and it will depend on the internet gateway creation
resource "aws_nat_gateway" "nat" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id = "${aws_subnet.Public_subnet1_eu_west_1a.id}"
    depends_on = ["aws_internet_gateway.gw"]
}

# Associate subnet Pub_subnet_eu_west_1 to public route table
resource "aws_route_table_association" "Public_subnet_eu_west_1a_association" {
    subnet_id = "${aws_subnet.Public_subnet1_eu_west_1a.id}"
    route_table_id = "${aws_vpc.vpc_tuto.main_route_table_id}"
}

resource "aws_route_table_association" "Public_subnet_eu_west_1b_association" {
    subnet_id = "${aws_subnet.Public_subnet2_eu_west_1b.id}"
    route_table_id = "${aws_vpc.vpc_tuto.main_route_table_id}"
}

resource "aws_route_table_association" "Public_subnet_eu_west_1c_association" {
    subnet_id = "${aws_subnet.Public_subnet3_eu_west_1c.id}"
    route_table_id = "${aws_vpc.vpc_tuto.main_route_table_id}"
}

# Associate subnet subnet_eu_west_1b to private route table
resource "aws_route_table_association" "subnet_eu_west_1b_association" {
    subnet_id = "${aws_subnet.Private_subnet_eu_west_1b.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}

# Associate subnet subnet_eu_west_1c to private route table
resource "aws_route_table_association" "subnet_eu_west_1c_association" {
    subnet_id = "${aws_subnet.Private_subnet_eu_west_1c.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}