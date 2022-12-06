#!/bin/bash

echo -e "\n==> Create trades topic in the principal cluster"
curl -X POST http://localhost:8081/subjects/trades-value/versions \
    -H 'Content-Type: application/json' \
    -d '{
        "schema": "{\"type\":\"record\",\"name\":\"trades\",\"fields\":[{\"name\":\"stock\",\"type\":\"string\"}, {\"name\":\"price\",\"type\":\"float\"}]}",
        "schemaType": "AVRO"
    }'

sleep 1