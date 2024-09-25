locals {
  logs_annotation = var.logs_bucket_name != null ? "access_logs.s3.enabled=true,access_logs.s3.bucket=${var.logs_bucket_name},access_logs.s3.prefix=${var.module_prefix}" : ""
}

resource "kubernetes_namespace" "neo4j" {
  metadata {
    name = "neo4j"
  }
}

resource "helm_release" "neo4j" {
  name              = var.module_prefix
  chart             = "neo4j"
  repository        = "https://neo4j.github.io/helm-charts/"
  version           = var.neo4j_helm_chart_version
  timeout           = 600
  wait              = var.wait
  dependency_update = var.dependency_update
  namespace         = kubernetes_namespace.neo4j.metadata[0].name

  values = [
    templatefile(
      "${path.module}/templates/neo4j_values.yaml",
      {
        module_prefix            = "${var.module_prefix}",
        neo4j_root_user_password = "${var.neo4j_root_user_password}",

        neo4j_dns_name     = "${local.neo4j_dns_name}",
        subdomain_cert_arn = "${var.subdomain_cert_arn}",
        tags               = "environment=${var.env}",

        allowed_cidr_blocks = "${join(",", var.allowed_cidr_blocks)}",
        security_group_ids = "${join(",", [
          aws_security_group.allow_from_lb_to_eks_clusterf.id,
          aws_security_group.security_group_to_allow_traffic_to_7687.id,
        ])}",
        public_subnet_ids = "${join(",", var.public_subnet_ids)}",

        subdomain_cert_arn   = var.subdomain_cert_arn,
        logs_annotation      = "${local.logs_annotation}",
        neo4j_dns_name       = "${local.neo4j_dns_name}",
        neo4j_admin_dns_name = "${local.neo4j_admin_dns_name}"
        # existing_secret_name        = "${kubernetes_secret_v1.neo4j_secrets.metadata[0].name}",
      }
    )
  ]
}

