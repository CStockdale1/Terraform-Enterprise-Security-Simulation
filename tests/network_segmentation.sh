#!/bin/bash

set -e

echo "Company Security Lab Network Segmentation Tests"
echo

echo "Testing public web service..."

if curl -fsS http://localhost:8080 >/dev/null; then
    echo "PASS: Public web service is reachable."
else
    echo "FAIL: Public web service is not reachable."
    exit 1
fi

echo
echo "Testing web-to-application communication..."

if docker exec company-web nc -z -w 2 company-application 80 >/dev/null 2>&1; then
    echo "PASS: Web service can reach the application tier."
else
    echo "FAIL: Web service cannot reach the application tier."
    exit 1
fi

echo
echo "Testing application-to-database communication..."

if docker exec company-application nc -z -w 2 company-database 5432 >/dev/null 2>&1; then
    echo "PASS: Application tier can reach the database tier."
else
    echo "FAIL: Application tier cannot reach the database tier."
    exit 1
fi

echo
echo "Testing web-to-database isolation..."

if docker exec company-web nc -z -w 2 company-database 5432 >/dev/null 2>&1; then
    echo "FAIL: Web service can reach the database tier."
    exit 1
else
    echo "PASS: Web service cannot reach the database tier."
fi

echo
echo "Checking database network isolation..."

DB_NETWORKS=$(docker inspect company-database \
    --format '{{range $name, $value := .NetworkSettings.Networks}}{{$name}} {{end}}')

if [[ "$DB_NETWORKS" == *"company-database"* ]] && \
   [[ "$DB_NETWORKS" != *"company-public"* ]]; then
    echo "PASS: Database is isolated from the public network."
else
    echo "FAIL: Database network segmentation is incorrect."
    exit 1
fi

echo
echo "Checking application network placement..."

APP_NETWORKS=$(docker inspect company-application \
    --format '{{range $name, $value := .NetworkSettings.Networks}}{{$name}} {{end}}')

if [[ "$APP_NETWORKS" == *"company-application"* ]] && \
   [[ "$APP_NETWORKS" == *"company-database"* ]] && \
   [[ "$APP_NETWORKS" != *"company-public"* ]]; then
    echo "PASS: Application is isolated from the public network."
else
    echo "FAIL: Application network segmentation is incorrect."
    exit 1
fi

echo
echo "All network segmentation tests passed."
