resource "random_uuid" "uuid" {}

resource "aws_s3_bucket" "webapp_bucket" {
  bucket        = "webapp-${random_uuid.uuid.result}"
  force_destroy = true

  tags = {
    Name = "webapp-bucket"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "webapp_bucket_lifecycle" {
  bucket = aws_s3_bucket.webapp_bucket.id

  rule {
    id     = "Move_To_IA"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = var.storage_class
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "webapp_bucket_encryption" {
  bucket = aws_s3_bucket.webapp_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.encrypt_algo
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
  }
}

