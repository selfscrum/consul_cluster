output "cluster_tag_key" {
  value       = var.cluster_tag_key
  description = "This is the tag key used to allow the consul servers to autojoin"
}

output "cluster_tag_value" {
  value       = var.cluster_tag_value
  description = "This is the tag value used to allow the consul servers to autojoin"
}

