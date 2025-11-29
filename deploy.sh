#!/bin/bash
docker compose down || true
docker compose up -d --build