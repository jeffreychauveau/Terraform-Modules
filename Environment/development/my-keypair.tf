resource "aws_key_pair" "my-key-pair" {
  key_name   = "my-key"
  public_key = file("../my-key.pub")
}
