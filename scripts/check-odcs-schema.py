"""Validate the real R exporter output against the vendored upstream schema."""
import json
from pathlib import Path
from jsonschema import Draft201909Validator
schema = json.loads(Path("packages/dataraft.adapters/inst/schema/odcs-json-schema-v3.2.0.json").read_text())
document = json.loads(Path("accessibility-artifacts/contract.odcs.json").read_text())
Draft201909Validator(schema).validate(document)
print("ODCS 3.2 exporter fixture conforms to the upstream JSON Schema")
