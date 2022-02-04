#!/bin/bash

# source https://github.com/dumrauf/openvpn-terraform-install/blob/master/scripts/update_users.sh

# Note that this Bash script relies on the the following assumption to work correctly:
# For each input into this script as 'CLIENT', the underlying 'openvpn-install.sh' Bash script creates a certificate nameded 'CLIENT.ovpn'.
# _Excess client certificates_ are then defined as provsioned client certificates that have no corresponding entry in the input to this script.


# Set the nullglob option so that the array is empty if there are no matches; see also <https://stackoverflow.com/a/10981499> for details
shopt -s nullglob

# Input paramter checking and alerting if there are none (which is synonymous with revoking all client certificates)
if [[ "$#" -eq "0" ]]
then
  script_name=$(basename "$0")
  echo "Usage: ${script_name} <username1> ... <usernameN>"
  echo "Example: ${script_name} userOne"
  echo "Example: ${script_name} userOne userTwo"
  echo ""
	until [[ $REVOKE_ALL_CLIENT_CERTIFICATES =~ ^(Y|n)$ ]]; do
    read -p "You've supplied no username. This will REVOKE ALL CLIENT CERTIFICATES! Are you sure? [Y/n]" -n 1 -r REVOKE_ALL_CLIENT_CERTIFICATES
    echo ""
  done
  if [[ $REVOKE_ALL_CLIENT_CERTIFICATES =~ ^[Y]$ ]]
  then
    echo "Alright. REVOKING ALL CLIENT CERTIFICATES then..."
  else
    echo "Aborting."
    exit -1
  fi
fi

# Declare all additional parameters to be user names
USERNAMES="$@"

# Create a list of provisioned OVPN users from existing *.ovpn files
ovpn_users=( $(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | tr '\n' ' ') )

# Revoke excess client certificates
for ovpn_user in ${ovpn_users[@]}
do
  if [[ "$USERNAMES" =~ "$ovpn_user" ]];
  then
    echo "Keeping certificate for user ${ovpn_user}."
  else
    echo "Revoking certificate for user ${ovpn_user}!"

    # Export the corresponding options and revoke the user certificate
    export MENU_OPTION="2"
    export CLIENT="${ovpn_user}"
    export DNS="9"
    searchRegex="${ovpn_user}$"
    export CLIENTNUMBER=$(echo $(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep "^V" | cut -d '=' -f 2 | nl -s ') '|grep -n $searchRegex)|head -c 1)
    ./openvpn-install.sh
  fi
done

client_template="/etc/openvpn/client-template.txt"
echo "\n\nRoute private IPs $ROUTE_ONLY_PRIVATE_IPS\n\n"
if [[ "$ROUTE_ONLY_PRIVATE_IPS" = "true" ]]; then
  grep -qxF 'route-nopull' $client_template|| echo 'route-nopull' >> $client_template
  grep -qxF 'route 10.0.0.0 255.0.0.0 10.8.0.1' $client_template || echo 'route 10.0.0.0 255.0.0.0 10.8.0.1' >> $client_template
  grep -qxF 'route 172.16.0.0 255.240.0.0 10.8.0.1' $client_template || echo 'route 172.16.0.0 255.255.0.0 10.8.0.1' >> $client_template
  grep -qxF 'route 192.168.0.0 255.255.0.0 10.8.0.1' $client_template || echo 'route 192.168.0.0 255.255.0.0 10.8.0.1' >> $client_template
fi

# Provision an OVPN file for each new user
for username in ${USERNAMES}
do
  # Skip all user names that already have a corresponding OVPN file
  ovpn_filename="${username}.ovpn"
  if [ -f "${ovpn_filename}" ]
  then
      echo "File '${ovpn_filename}' already exists. Skipping."
      continue
  fi

  # Export the corresponding options and add the user name
  export MENU_OPTION="1"
  export CLIENT="${username}"
  export PASS="1"
  export DNS="9"
  ./openvpn-install.sh
done
