#!/usr/bin/env bash
poetry install
poetry export -f requirements.txt --output requirements.txt