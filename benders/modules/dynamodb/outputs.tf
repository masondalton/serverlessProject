output "table_name" {
  value = aws_dynamodb_table.four_nations.name
}

output "table_arn" {
  value = aws_dynamodb_table.four_nations.arn
}
