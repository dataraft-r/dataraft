#!/usr/bin/env bash
set -euo pipefail
# Coordinated changes update family-lock.json explicitly. Never infer moving branches.
python scripts/checkout-family.py
