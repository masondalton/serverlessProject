output "pipeline_name" {
  value = aws_codepipeline.frontend.name
}

output "artifact_bucket" {
  value = aws_s3_bucket.artifacts.bucket
}
