#!/bin/bash

echo -e "\n==> Failover mirroring topis trades and _schemas in the dr cluster"
docker-compose exec broker-dr kafka-mirrors --failover --topics trades,_schemas --bootstrap-server broker-dr:19092  

sleep 1

echo -e "\n==> Delete the cluster link premier->dr"
docker-compose exec broker-dr kafka-cluster-links --bootstrap-server broker-dr:19092 --delete --link premier-cluster-link

echo -e "\n==> Recreate the principal cluster without the schema registry"
docker-compose up -d zookeeper-premier broker-premier

sleep 5

echo -e "\n==> Create the cluster link premier<-dr"
docker-compose exec broker-premier kafka-cluster-links --bootstrap-server broker-premier:19091 --create --link dr-cluster-link --config bootstrap.servers=broker-dr:19092

echo -e "\n==> Restore _schemas and trades topic mirrored in the principal cluster"
docker-compose exec broker-premier kafka-mirrors --create --bootstrap-server broker-premier:19091 --mirror-topic trades --link dr-cluster-link
docker-compose exec broker-premier kafka-mirrors --create --bootstrap-server broker-premier:19091 --mirror-topic _schemas --link dr-cluster-link

echo -e "\n==> Check if the 100's messages are correctly restored in the principal cluster"
docker exec broker-premier kafka-console-consumer --bootstrap-server broker-premier:19091 --property print.key=true --topic trades --from-beginning --max-messages 100

echo -e "\n==> Promote trades and _schemas topics as writable in the principal cluster"
docker exec broker-premier kafka-mirrors --promote --topics trades,_schemas --bootstrap-server broker-premier:19091

while [[ "$(docker exec broker-premier kafka-mirrors --describe --pending-stopped-only --bootstrap-server broker-premier:19091
)" != "No mirror topics found." ]];
do
sleep 1;
done

echo -e "\n==> Delete the cluster link premier<-dr"
docker exec broker-premier kafka-cluster-links --bootstrap-server broker-premier:19091 --delete --link dr-cluster-link

sleep 1;

echo -e "\n==> Start a new instance of the schema registry in the principal cluster"
docker-compose up -d schema-registry-premier

# Wait SR is up and ready
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:8081)" != "200" ]]; 
do 
sleep 1; 
done

echo -e "\n==> Check if the 100's messages are correctly readable with the new schema registry"
docker exec schema-registry-premier kafka-avro-console-consumer --bootstrap-server broker-premier:19091 --property schema.registry.url=http://localhost:8081 --topic trades --from-beginning --max-messages 100

echo -e "\n==> Delete trades and _schemas topics in the dr cluster"
docker-compose exec broker-dr kafka-topics --bootstrap-server broker-dr:19092 --delete --topic trades
docker-compose exec broker-dr kafka-topics --bootstrap-server broker-dr:19092 --delete --topic _schemas
