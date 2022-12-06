#!/bin/bash

echo -e "\n==> Produce 100 messages into the trades topic in the principal cluster"
seq -f "User:123345|{\"stock\": \"Apple\", \"price\": %.2f}" 100 | docker exec -i schema-registry-premier kafka-avro-console-producer --bootstrap-server broker-premier:19091 --property schema.registry.url=http://localhost:8081 --topic trades --property value.schema='{"type":"record","name":"trades","fields":[{"name":"stock","type":"string"}, {"name":"price","type":"float"}]}' --property parse.key=true --property key.separator=\| --property key.serializer=org.apache.kafka.common.serialization.StringSerializer

sleep 3

echo -e "\n==> Check if the 100's messages are correctly mirrored in the dr cluster"
docker exec broker-dr kafka-console-consumer --bootstrap-server broker-dr:19092 --property print.key=true --topic trades --from-beginning --max-messages 100