output "instance_id" {
  value = aws_instance.sample_app_instance.id
}

output "instance_public_dns" {
  value = aws_instance.sample_app_instance.public_dns
}
