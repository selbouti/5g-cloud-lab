#!/bin/bash

# Lancer le gNB
sudo docker run -d --name ueransim-gnb \
  --network overlay-radio \
  --privileged \
  -v ~/5g-cloud-lab/srsran/gnb.yaml:/etc/ueransim/gnb.yaml \
  towards5gs/free5gc-ueransim:latest \
  nr-gnb -c /etc/ueransim/gnb.yaml

# Attendre que le gNB soit prêt
sleep 5

# Lancer l'UE
sudo docker run -d --name ueransim-ue \
  --network overlay-radio \
  --privileged \
  -v ~/5g-cloud-lab/srsran/ue.yaml:/etc/ueransim/ue.yaml \
  towards5gs/free5gc-ueransim:latest \
  nr-ue -c /etc/ueransim/ue.yaml
