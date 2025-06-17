#!/bin/bash

# Script to stop all OpenVPN sessions

# Get a list of active OpenVPN sessions
sessions=$(openvpn3 sessions-list | grep "Path:" | awk '{print $2}')

if [ -z "$sessions" ]; then
  echo "No active OpenVPN sessions found."
  exit 0
fi

echo "Stopping active OpenVPN sessions..."

# Iterate through the list of sessions and disconnect each one
for session in $sessions; do
  echo "Disconnecting session: $session"
  openvpn3 session-manage --session-path "$session" --disconnect
done

echo "All active OpenVPN sessions stopped."
