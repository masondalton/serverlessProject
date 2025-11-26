variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

resource "aws_dynamodb_table" "four_nations" {
  name         = "${var.project_name}-${var.environment}-table"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "EntityType"
  range_key = "EntityID"

  attribute {
    name = "EntityType"
    type = "S"
  }

  attribute {
    name = "EntityID"
    type = "S"
  }
}

# Example seed items – add more here as you go
resource "aws_dynamodb_table_item" "bender_aang" {
  table_name = aws_dynamodb_table.four_nations.name
  hash_key   = "EntityType"
  range_key  = "EntityID"

  item = jsonencode({
    EntityType = { S = "Bender" }
    EntityID   = { S = "Aang" }
    name       = { S = "Aang" }
    nation     = { S = "Air" }
    elements   = { SS = ["Air"] }
    imageUrl   = { S = "https://example.com/aang.png" }
    bio        = { S = "Last Airbender; lover of cabbages." }
  })
}
