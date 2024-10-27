resource "random_uuid" "uuid" {}

resource "aws_s3_bucket" "webapp_bucket" {
  bucket        = "webapp-${random_uuid.image_uuid.result}"
  force_destroy = true

  tags = {
    Name = "webapp-bucket"
  }
}

resource "aws_s3_bucket_acl" "webapp_bucket_acl" {
  bucket = aws_s3_bucket.webapp_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle_config" {
  bucket = aws_s3_bucket.webapp_bucket.id

  rule {
    id     = "Move_To_IA"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
