#!/bin/bash

echo -e "\n==> Create trades topic in the principal cluster"
docker-compose  \
	exec broker-premier kafka-topics  --create \
	--bootstrap-server broker-premier:19091 \
	--topic trades \
	--partitions 1 \
	--replication-factor 1 \
	--config min.insync.replicas=1

sleep 2

echo -e "\n==> Create the cluster link premier->dr"
docker-compose  \
	exec broker-dr kafka-cluster-links \
	--bootstrap-server broker-dr:19092 \
	--create \
	--link premier-cluster-link \
	--config bootstrap.servers=broker-premier:19091

sleep 2

echo -e "\n==> Create an disaster recovery trades topic mirrored of principal trades topic"
docker-compose \
	exec broker-dr kafka-mirrors --create \
	--bootstrap-server broker-dr:19092 \
	--mirror-topic trades \
	--link premier-cluster-link

sleep 2

echo -e "\n==> Create an disaster recovery _schemas topic mirrored of principal _schemas topic"
docker-compose  \
	exec broker-dr kafka-mirrors --create \
	--bootstrap-server broker-dr:19092 \
	--mirror-topic _schemas \
	--link premier-cluster-link

sleep 2