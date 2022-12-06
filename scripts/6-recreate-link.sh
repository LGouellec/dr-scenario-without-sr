#!/bin/bash

echo -e "\n==> Recreate the cluster link premier->dr"
docker-compose  \
	exec broker-dr kafka-cluster-links \
	--bootstrap-server broker-dr:19092 \
	--create \
	--link premier-cluster-link \
	--config bootstrap.servers=broker-premier:19091

sleep 2

echo -e "\n==> Recreate a disaster recovery trades topic mirrored of principal trades topic"
docker-compose \
	exec broker-dr kafka-mirrors --create \
	--bootstrap-server broker-dr:19092 \
	--mirror-topic trades \
	--link premier-cluster-link

sleep 2

echo -e "\n==> Recreate a disaster recovery _schemas topic mirrored of principal _schemas topic"
docker-compose  \
	exec broker-dr kafka-mirrors --create \
	--bootstrap-server broker-dr:19092 \
	--mirror-topic _schemas \
	--link premier-cluster-link

sleep 2