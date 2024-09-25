resource "aws_security_group" "neo4j_private_ingress_sg" {
  count = length(var.allowed_security_group_ids) == 0 ? 0 : 1

  name        = "${var.app_name}-ingress-internal"
  description = "Private ingress SG to apply to the neo4j app."
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "neo4j_private_ingress_allow_from_allowed_sg_ids" {
  count = length(var.allowed_security_group_ids) == 0 ? 0 : 1

  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_group_ids[count.index]

  security_group_id = aws_security_group.neo4j_private_ingress_sg.0.id
}

resource "aws_security_group_rule" "neo4j_private_ingress_allow_to_neo4j_container" {
  count = length(var.allowed_security_group_ids) == 0 ? 0 : 1

  type        = "egress"
  to_port     = 0
  from_port   = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.neo4j_private_ingress_sg.0.id
}

data "aws_subnet" "vpc_private_subnet_cidrs" {
  count = length(var.private_subnet_ids)
  id    = var.private_subnet_ids[count.index]
}

resource "aws_security_group_rule" "neo4j_private_ingress_allow_from_private_subnet_cidr_blocks" {
  count = length(var.private_subnet_ids) == 0 || length(aws_security_group.neo4j_private_ingress_sg) == 0 ? 0 : 1

  type        = "ingress"
  to_port     = 443
  from_port   = 443
  protocol    = "tcp"
  cidr_blocks = [for s in data.aws_subnet.vpc_private_subnet_cidrs : s.cidr_block]

  security_group_id = aws_security_group.neo4j_private_ingress_sg.0.id
  description       = "Allow from private subnet CIDRs."
}

locals {
  neo4j_private_ingress_sg_ids = length(var.allowed_security_group_ids) == 0 ? [] : [aws_security_group.neo4j_private_ingress_sg.0.id]
}

# Create the load balancer security group
resource "aws_security_group" "security_group_to_allow_traffic_to_7687" {
  name        = "allow_traffic_to_7687"
  description = "Security group with specific rules"
  vpc_id      = var.vpc_id
}

# Ingress rule: Allow traffic from anywhere on port 7687
resource "aws_security_group_rule" "ingress_port_7687" {
  type              = "ingress"
  from_port         = 7687
  to_port           = 7687
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security_group_to_allow_traffic_to_7687.id
  description       = "Allow traffic on port 7687 from anywhere"
}

# Ingress rule: Allow traffic from allowed_cidr_blocks on ports 0-7686 (below port 7687)
resource "aws_security_group_rule" "ingress_specific_ip_below_7687" {
  type              = "ingress"
  from_port         = 0
  to_port           = 7686
  protocol          = "tcp"
  cidr_blocks       = [for s in var.adhoc_cidr_blocks : s]
  security_group_id = aws_security_group.security_group_to_allow_traffic_to_7687.id
  description       = "Allow traffic from allowed_cidr_blocks on ports 0-7686"
}

# Ingress rule: Allow traffic from allowed_cidr_blocks on ports 7688-65535 (above port 7687)
resource "aws_security_group_rule" "ingress_specific_ip_above_7687" {
  type              = "ingress"
  from_port         = 7688
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [for s in var.adhoc_cidr_blocks : s]
  security_group_id = aws_security_group.security_group_to_allow_traffic_to_7687.id
  description       = "Allow traffic from allowed_cidr_blocks on ports 7688-65535"
}

# Egress rule: Allow all outbound traffic
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"  # -1 means all protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security_group_to_allow_traffic_to_7687.id
  description       = "Allow all outbound traffic"
}

# Create another security group for load balancer (cluster level configs?? I don't know man ¯\_(ツ)_/¯)
resource "aws_security_group" "security_group_to_allow_outbound_traffic" {
  name        = "allow_outbound_traffic"
  description = "Security group with specific rules"
  vpc_id      = var.vpc_id
}

# Egress rule: Allow all outbound traffic
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"  # -1 means all protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security_group_to_allow_outbound_traffic.id
  description       = "Allow all outbound traffic"
}
