output "neo4j_private_lb_sg_id" {
  description = "Private LB security group."
  value       = length(var.allowed_security_group_ids) == 0 ? null : aws_security_group.neo4j_private_ingress_sg.0.id
}
