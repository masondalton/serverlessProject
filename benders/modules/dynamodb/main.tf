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
    imageUrl   = { S = "/img/aang.jpeg" }
    bio        = { S = "Last Airbender; lover of cabbages." }
  })
}

resource "aws_dynamodb_table_item" "bender_katara" {
  table_name = aws_dynamodb_table.four_nations.name
  hash_key   = "EntityType"
  range_key  = "EntityID"

  item = jsonencode({
    EntityType = { S = "Bender" }
    EntityID   = { S = "Katara" }
    name       = { S = "Katara" }
    nation     = { S = "Water" }
    elements   = { SS = ["Water"] }
    imageUrl   = { S = "/img/katara.jpeg" }
    bio        = { S = "Master Waterbender and healer from the Southern Water Tribe." }
  })
}

resource "aws_dynamodb_table_item" "bender_toph" {
  table_name = aws_dynamodb_table.four_nations.name
  hash_key   = "EntityType"
  range_key  = "EntityID"

  item = jsonencode({
    EntityType = { S = "Bender" }
    EntityID   = { S = "Toph" }
    name       = { S = "Toph Beifong" }
    nation     = { S = "Earth" }
    elements   = { SS = ["Earth", "Metal"] }
    imageUrl   = { S = "/img/toph.jpeg" }
    bio        = { S = "Blind Bandit and inventor of metalbending." }
  })
}

resource "aws_dynamodb_table_item" "bender_zuko" {
  table_name = aws_dynamodb_table.four_nations.name
  hash_key   = "EntityType"
  range_key  = "EntityID"

  item = jsonencode({
    EntityType = { S = "Bender" }
    EntityID   = { S = "Zuko" }
    name       = { S = "Prince Zuko" }
    nation     = { S = "Fire" }
    elements   = { SS = ["Fire", "Lightning"] }
    imageUrl   = { S = "/img/zuko.jpeg" }
    bio        = { S = "Banished prince turned Fire Lord; master of dual-wielding broadswords." }
  })
}

resource "aws_dynamodb_table_item" "nation_air" {
  table_name = aws_dynamodb_table.four_nations.name
  hash_key   = "EntityType"
  range_key  = "EntityID"

  item = jsonencode({
    EntityType = { S = "Nation" }
    EntityID   = { S = "Air" }
    name       = { S = "Air Nomads" }
    lore       = { S = "Peaceful monastic culture; bending style rooted in Ba Gua Zhang and freedom." }
    imageUrl   = { S = "/img/air-nation.jpeg" }
  })
}

resource "aws_dynamodb_table_item" "nation_water" {
  table_name = aws_dynamodb_table.four_nations.name
  hash_key   = "EntityType"
  range_key  = "EntityID"

  item = jsonencode({
    EntityType = { S = "Nation" }
    EntityID   = { S = "Water" }
    name       = { S = "Water Tribe" }
    lore       = { S = "Northern and Southern Tribes thrive on adaptability, healing, and tidal forms." }
    imageUrl   = { S = "/img/water-tribe.jpeg" }
  })
}

resource "aws_dynamodb_table_item" "nation_earth" {
  table_name = aws_dynamodb_table.four_nations.name
  hash_key   = "EntityType"
  range_key  = "EntityID"

  item = jsonencode({
    EntityType = { S = "Nation" }
    EntityID   = { S = "Earth" }
    name       = { S = "Earth Kingdom" }
    lore       = { S = "Stoic, rooted, and enduring; home of Omashu, Ba Sing Se, and metalbending origins." }
    imageUrl   = { S = "/img/earth-kingdom.jpeg" }
  })
}

resource "aws_dynamodb_table_item" "nation_fire" {
  table_name = aws_dynamodb_table.four_nations.name
  hash_key   = "EntityType"
  range_key  = "EntityID"

  item = jsonencode({
    EntityType = { S = "Nation" }
    EntityID   = { S = "Fire" }
    name       = { S = "Fire Nation" }
    lore       = { S = "Power from breath and drive; balanced by the Sun Warriors’ original teachings." }
    imageUrl   = { S = "/img/fire-nation.png" }
  })
}

resource "aws_dynamodb_table_item" "technique_ice_shield" {
  table_name = aws_dynamodb_table.four_nations.name
  hash_key   = "EntityType"
  range_key  = "EntityID"

  item = jsonencode({
    EntityType   = { S = "Technique" }
    EntityID     = { S = "Water-Ice-Shield" }
    name         = { S = "Ice Shield" }
    element      = { S = "Water" }
    difficulty   = { S = "Intermediate" }
    origin       = { S = "Northern Water Tribe" }
    description  = { S = "Rapidly freezes water into a defensive barrier to deflect projectiles." }
    imageUrl     = { S = "/img/ice-shield.jpeg" }
  })
}

resource "aws_dynamodb_table_item" "technique_metalbending" {
  table_name = aws_dynamodb_table.four_nations.name
  hash_key   = "EntityType"
  range_key  = "EntityID"

  item = jsonencode({
    EntityType   = { S = "Technique" }
    EntityID     = { S = "Earth-Metalbending" }
    name         = { S = "Metalbending" }
    element      = { S = "Earth" }
    difficulty   = { S = "Advanced" }
    origin       = { S = "Beifong School" }
    description  = { S = "Manipulates trace earth within metal to bend refined structures." }
    imageUrl     = { S = "/img/metalbending.jpeg" }
  })
}

resource "aws_dynamodb_table_item" "technique_lightning" {
  table_name = aws_dynamodb_table.four_nations.name
  hash_key   = "EntityType"
  range_key  = "EntityID"

  item = jsonencode({
    EntityType   = { S = "Technique" }
    EntityID     = { S = "Fire-Lightning-Redirection" }
    name         = { S = "Lightning Redirection" }
    element      = { S = "Fire" }
    difficulty   = { S = "Advanced" }
    origin       = { S = "Fire Nation Royal Line" }
    description  = { S = "Channels lightning through the body’s paths to safely discharge it." }
    imageUrl     = { S = "/img/lightning-redirection.jpeg" }
  })
}

resource "aws_dynamodb_table_item" "technique_air_scooter" {
  table_name = aws_dynamodb_table.four_nations.name
  hash_key   = "EntityType"
  range_key  = "EntityID"

  item = jsonencode({
    EntityType   = { S = "Technique" }
    EntityID     = { S = "Air-Air-Scooter" }
    name         = { S = "Air Scooter" }
    element      = { S = "Air" }
    difficulty   = { S = "Beginner" }
    origin       = { S = "Air Nomads" }
    description  = { S = "A spinning sphere of air used for agile movement and quick travel." }
    imageUrl     = { S = "/img/air-scooter.jpeg" }
  })
}
