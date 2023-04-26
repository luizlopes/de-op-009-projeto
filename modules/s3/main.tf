resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
  force_destroy = true

  tags = {
    Name = "bootcamp"
    Turma = "DE-OP-009-983"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}

output "bucket_id" {
  value = aws_s3_bucket.my_bucket.bucket
}