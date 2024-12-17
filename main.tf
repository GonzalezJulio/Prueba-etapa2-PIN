resource "aws_instance" "webserver_setup" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.subnet.id
  user_data                   = file("create_apache.sh")

  tags = {
    Name = "webserver_setup"
  }
}


