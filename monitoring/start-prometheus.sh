#!/bin/bash
sudo docker rm -f prometheus 2>/dev/null

sudo docker run -d --name prometheus \
  --network host \
  -v ~/5g-cloud-lab/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml \
  --restart always \
  prom/prometheus:latest

sudo docker network connect overlay-5g prometheus
sudo docker network connect overlay-radio prometheus
sudo docker network connect overlay-op prometheus
