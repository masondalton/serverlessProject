import json
import os
import boto3
from boto3.dynamodb.conditions import Attr

REGION = os.environ.get("REGION")
TABLE_NAME = os.environ["TABLE_NAME"]
table = boto3.resource("dynamodb", region_name=REGION).Table(TABLE_NAME)


def respond(status, body):
    return {
        "statusCode": status,
        "headers": {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body)
    }


def clean(obj):
    """Convert DynamoDB types (e.g., sets) to JSON-serializable structures."""
    if isinstance(obj, set):
        return list(obj)
    if isinstance(obj, list):
        return [clean(o) for o in obj]
    if isinstance(obj, dict):
        return {k: clean(v) for k, v in obj.items()}
    return obj


def parse_body(event):
    try:
        return json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return {}


def get_benders(event, context):
    params = event.get("queryStringParameters") or {}
    nation_filter = params.get("nation")
    element_filter = params.get("element")

    try:
        resp = table.scan(FilterExpression=Attr("EntityType").eq("Bender"))
        items = resp.get("Items", [])
    except Exception as exc:
        return respond(500, {"error": f"scan failed: {exc}"})

    # Apply filters in Python to avoid Dynamo filter quirks
    if nation_filter:
        items = [i for i in items if i.get("nation") == nation_filter]
    if element_filter:
        items = [i for i in items if element_filter in (i.get("elements") or [])]

    return respond(200, clean(items))


def get_techniques(event, context):
    params = event.get("queryStringParameters") or {}
    filter_expr = Attr("EntityType").eq("Technique")

    if params.get("element"):
        filter_expr = filter_expr & Attr("element").eq(params["element"])

    try:
        resp = table.scan(FilterExpression=filter_expr)
        items = resp.get("Items", [])
    except Exception as exc:
        return respond(500, {"error": str(exc)})

    return respond(200, items)


def get_nation_lore(event, context):
    name = (event.get("pathParameters") or {}).get("name")
    if not name:
        return respond(400, {"error": "Missing nation name"})

    try:
        resp = table.get_item(
            Key={"EntityType": "Nation", "EntityID": name}
        )
    except Exception as exc:
        return respond(500, {"error": str(exc)})

    item = resp.get("Item")
    if not item:
        return respond(404, {"error": "Nation not found"})

    return respond(200, item)


def suggest_element(event, context):
    answers = parse_body(event).get("answers", [])
    choices = ["Air", "Water", "Earth", "Fire"]
    if not answers:
        return respond(200, {"element": "Air"})

    score = sum(len(str(a)) for a in answers)
    chosen = choices[score % len(choices)]
    return respond(200, {"element": chosen})


def create_or_update_bender(event, context):
    payload = parse_body(event)
    bender_id = payload.get("id") or payload.get("name")
    name = payload.get("name")
    nation = payload.get("nation")
    elements = payload.get("elements")

    if not bender_id or not name or not nation or not elements:
        return respond(400, {"error": "id/name/nation/elements are required"})

    item = {
        "EntityType": "Bender",
        "EntityID": bender_id,
        "name": name,
        "nation": nation,
        "elements": elements,
        "imageUrl": payload.get("imageUrl", ""),
        "bio": payload.get("bio", "")
    }

    try:
        table.put_item(Item=item)
    except Exception as exc:
        return respond(500, {"error": str(exc)})

    return respond(200, {"message": "Bender upserted", "bender": item})


def delete_bender(event, context):
    bender_id = (event.get("pathParameters") or {}).get("id")
    if not bender_id:
        return respond(400, {"error": "Missing bender id"})

    try:
        table.delete_item(
            Key={"EntityType": "Bender", "EntityID": bender_id},
            ConditionExpression=Attr("EntityID").exists()
        )
    except table.meta.client.exceptions.ConditionalCheckFailedException:
        return respond(404, {"error": "Bender not found"})
    except Exception as exc:
        return respond(500, {"error": str(exc)})

    return respond(200, {"message": "Bender deleted", "id": bender_id})


def create_or_update_technique(event, context):
    payload = parse_body(event)
    tech_id = payload.get("id") or payload.get("name")
    name = payload.get("name")
    element = payload.get("element")
    difficulty = payload.get("difficulty", "Intermediate")
    origin = payload.get("origin", "")
    description = payload.get("description", "")

    if not tech_id or not name or not element:
        return respond(400, {"error": "id/name/element are required"})

    item = {
        "EntityType": "Technique",
        "EntityID": tech_id,
        "name": name,
        "element": element,
        "difficulty": difficulty,
        "origin": origin,
        "description": description,
    }

    try:
        table.put_item(Item=item)
    except Exception as exc:
        return respond(500, {"error": str(exc)})

    return respond(200, {"message": "Technique upserted", "technique": item})


def delete_technique(event, context):
    tech_id = (event.get("pathParameters") or {}).get("id")
    if not tech_id:
        return respond(400, {"error": "Missing technique id"})

    try:
        table.delete_item(
            Key={"EntityType": "Technique", "EntityID": tech_id},
            ConditionExpression=Attr("EntityID").exists()
        )
    except table.meta.client.exceptions.ConditionalCheckFailedException:
        return respond(404, {"error": "Technique not found"})
    except Exception as exc:
        return respond(500, {"error": str(exc)})

    return respond(200, {"message": "Technique deleted", "id": tech_id})
