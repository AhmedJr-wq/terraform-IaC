# App security group: every ingress port restricted to a caller-supplied CIDR,
# enforced by variable validation rather than convention -- this is where the
# "never 0.0.0.0/0" guarantee from the incident this lab is based on actually
# gets baked in for every future caller, not just checked by a reviewer.

resource "aws_security_group" "app" {
  name = "${var.project_tag}-app-sg"
  # NOTE: this top-level description is `ForceNew` on aws_security_group --
  # changing it destroys/recreates the whole SG. Left as the original literal
  # text (rather than reworded for the generic module) so refactoring this
  # module doesn't force a replace of an already-applied security group.
  description = "Kente Retail staging app: SSH and app port, both restricted to allowed_ssh_cidr."
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      description = "TCP port ${ingress.value} -- restricted to allowed_cidr"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.allowed_cidr]
    }
  }

  egress {
    description = "Unrestricted outbound -- fine for a staging box"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_tag}-app-sg"
    Project = var.project_tag
  }
}
