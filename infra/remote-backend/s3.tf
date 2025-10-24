# S3 bucket for storing Terraform state
resource "aws_s3_bucket" "tf_state" {
  bucket = "project-bedrock-tfstate-my-project" # must be globally unique
}

# Enable versioning for state rollback
resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}