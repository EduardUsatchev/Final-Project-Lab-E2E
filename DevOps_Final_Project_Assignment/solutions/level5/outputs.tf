output "instance_id" {
  value = aws_instance.level5_instance.id
}

output "instance_public_dns" {
  value = aws_instance.level5_instance.public_dns
}

output "ebs_volume_id" {
  value = aws_ebs_volume.level5_ebs.id
}
