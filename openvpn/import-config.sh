#!/bin/bash

# Script to import an OpenVPN configuration file

if [ -z "$1" ]; then
  echo "Usage: $0 <config_file>"
  exit 1
fi
if [ -z "$2" ]; then
  echo "Usage: $0 <config_file> <config_name>"
  exit 1
fi

config_file="$1"
config_name="$2"

if [ ! -f "$config_file" ]; then
  echo "Error: Configuration file '$config_file' not found."
  exit 1
fi

echo "Importing OpenVPN configuration from '$config_file'..."
openvpn3 config-import --config "$config_file" --name "$config_name" --persistent
openvpn3 config-acl --show --lock-down true --grant root --config "$config_name"
echo "OpenVPN configuration imported successfully."
