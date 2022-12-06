#!/bin/bash

docker-compose down -v
docker-compose up -d

while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:8081)" != "200" ]]; 
do 
sleep 1; 
done

echo "Finish stack is ready ..."

echo -e "\n=> Step 1 - Create principal topics and topics mirrored"
source ./scripts/1-create-topic.sh
echo -e "\n=> Step 2 - Create the schema AVRO 'trade' into the schema registry in the principal cluster"
source ./scripts/2-create-schema.sh
echo -e "\n=> Step 3 - Produce mock trades data in the principal cluster"
source ./scripts/3-produce-data.sh
echo -e "\n=> Step 4 - Boommm a disaster happens"
source ./scripts/4-disaster.sh
echo -e "\n=> Step 5 - Recovery process"
source ./scripts/5-recovery-process.sh
echo -e "\n=> Step 6 - Recreate linking and so on"
source ./scripts/6-recreate-link.sh
echo -e "\n=> Step 7 - Restart to produce data in the principal cluster without data lost"
source ./scripts/7-reproduce-data.sh

echo -e "\n=> Run ./stop.sh to clean all the stack"