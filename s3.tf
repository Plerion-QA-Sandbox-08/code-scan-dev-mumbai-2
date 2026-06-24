# S3 bucket with public access - security issues
# This file should generate infrastructure findings (exact count may vary based on Plerion detection)
resource "aws_s3_bucket" "public_bucket" {
  bucket = "my-public-bucket"
}

# Public access block with 2 disabled blocks (may generate multiple findings)
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.public_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Public ACL (1 finding)
resource "aws_s3_bucket_acl" "public_acl" {
  bucket = aws_s3_bucket.public_bucket.id
  acl    = "public-read"
}

# Public bucket policy allowing public read/write (1 finding)
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.public_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadWrite"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.public_bucket.arn}/*"
      }
    ]
  })
}

# Website hosting with public access (1 finding)
resource "aws_s3_bucket_website_configuration" "public_website" {
  bucket = aws_s3_bucket.public_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

