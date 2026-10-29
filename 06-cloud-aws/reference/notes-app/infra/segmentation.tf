# Three-tier segmentation, the cloud version of the Module 4 office design.
# Each tier accepts traffic only from the tier in front of it.

resource "aws_security_group" "web" {
  name        = "${var.name}-web-tier"
  description = "Web tier: HTTPS from the internet"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app" {
  name        = "${var.name}-app-tier"
  description = "App tier: only from the web tier"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description     = "App port, from the web tier only"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
}

resource "aws_security_group" "db" {
  name        = "${var.name}-db-tier"
  description = "Database tier: only from the app tier"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description     = "PostgreSQL, from the app tier only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.lab.id
  subnet_ids = [aws_subnet.private.id]

  # Only traffic from inside the VPC, in either direction
  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = aws_vpc.lab.cidr_block
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = aws_vpc.lab.cidr_block
    from_port  = 0
    to_port    = 0
  }
}
