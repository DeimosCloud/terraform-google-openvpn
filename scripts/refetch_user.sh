#!/bin/bash
if [[ "$REFETCH_USER_OVPN" = "true" ]];then
  scp -i $PRIVATE_KEY_FILE \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      $REMOTE_USER@$IP_ADDRESS:/home/$REMOTE_USER/*.ovpn .
else
  echo "Not fetching ovpn. All files upto date"
 fi
