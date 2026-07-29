resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-${var.environment}"
  public_key = tls_private_key.main.public_key_openssh

  tags = {
    Name = "${var.project_name}-${var.environment}-keypair"
  }
}

resource "aws_ssm_parameter" "private_key" {
  name  = "/${var.project_name}/${var.environment}/ssh-key"
  type  = "SecureString"
  value = tls_private_key.main.private_key_pem

  tags = {
    Name = "${var.project_name}-${var.environment}-ssh-key"
  }
}
