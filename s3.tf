provider "aws" {
      region = "us-east-1"
  
}
resource "aws_s3_bucket" "my_bucket" {
  bucket = "fgh-bucket-00"
  
  

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
resource "aws_s3_bucket_public_access_block" "public_access" {
      bucket = aws_s3_bucket.my_bucket.id

      block_public_acls       = false
      block_public_policy     = false
      ignore_public_acls      = false
      restrict_public_buckets = false
  
}
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = [
          "s3:GetObject",
          "s3:PutBucketPolicy"
        ]
        Resource  = "${aws_s3_bucket.my_bucket.arn}/*"
      }
    ]
  })
}
# locals {
#   source_files = fileset("Simple_project/dist", "*/*")
# }

locals {
  source_files = toset([
    "index.html",
    "style.css",
    "script.js"
  ])
}


resource "aws_s3_object" "file_uploads" {
      bucket_key_enabled = false

  for_each = local.source_files

  bucket = aws_s3_bucket.my_bucket.id
  key    = each.value
  source = "${path.module}/dist/${each.value}"
  etag   = filemd5("${path.module}/dist/${each.value}")
  #  Correct MIME type based on file extension
  content_type = lookup({
    html = "text/html",
    css  = "text/css",
    js   = "application/javascript"
  }, split(".", each.value)[1], "text/plain")


}
  

# This tells AWS to treat index.html as the main page
resource "aws_s3_bucket_website_configuration" "site" {
      bucket = aws_s3_bucket.my_bucket.id
      index_document {
        suffix = "index.html"
      }
      error_document {
        key = "index.html"
      }
  
}
