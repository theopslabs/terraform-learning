output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.this.id
}

output "instance_public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.this.public_ip
}

output "instance_availability_zone" {
  description = "Availability zone of the instance"
  value       = aws_instance.this.availability_zone
}

output "ami_id" {
  description = "AMI selected by the data source"
  value       = data.aws_ami.amazon_linux.id
}

output "ami_name" {
  description = "Name of the selected AMI"
  value       = data.aws_ami.amazon_linux.name
}
