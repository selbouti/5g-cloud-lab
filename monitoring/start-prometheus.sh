#!/bin/bash
sudo docker rm -f prometheus 2>/dev/null

sudo docker run -d --name prometheus \
  --network overlay-5g \
  --network overlay-radio \
  --network overlay-op \
  -p 9090:9090 \
  -v ~/5g-cloud-lab/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml \
  --restart always \
  prom/prometheus:latest
