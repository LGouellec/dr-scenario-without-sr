#!/bin/bash

echo -e "\n==> A disaster happens in the principal cluster."
echo -e "You have to create a cluster from scratch based on topic mirrored."
docker stop zookeeper-premier broker-premier schema-registry-premier
docker rm zookeeper-premier broker-premier schema-registry-premier