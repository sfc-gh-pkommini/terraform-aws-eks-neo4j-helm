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
