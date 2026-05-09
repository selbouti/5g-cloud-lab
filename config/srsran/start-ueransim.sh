#!/bin/bash

# Lancer le gNB
sudo docker rm -f ueransim-gnb 2>/dev/null
sudo docker run -d --name ueransim-gnb \
  --network overlay-radio \
  --privileged \
  --cap-add NET_ADMIN \
  -v ~/5g-cloud-lab/srsran/gnb.yaml:/ueransim/config/open5gs-gnb.yaml \
  free5gc/ueransim:latest \
  bash -c "nr-gnb -c /ueransim/config/open5gs-gnb.yaml"

sleep 5

# Lancer l'UE
sudo docker rm -f ueransim-ue 2>/dev/null
sudo docker run -d --name ueransim-ue \
  --network overlay-radio \
  --privileged \
  --cap-add NET_ADMIN \
  -v ~/5g-cloud-lab/srsran/ue.yaml:/ueransim/config/open5gs-ue.yaml \
  free5gc/ueransim:latest \
  bash -c "nr-ue -c /ueransim/config/open5gs-ue.yaml"
