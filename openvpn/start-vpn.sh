#!/bin/bash

# Source the .env file
if [ -f ".env" ]; then
  source .env
fi

# Get configuration from environment variables or use defaults
PYTHON_OTP_PATH=${VPN_OTP_SCRIPT}
VPN_USERNAME=${VPN_USERNAME}
VPN_PASSWORD=${VPN_PASSWORD}
VPN_CONFIG=${VPN_CONFIG}

# Get OTP code
vpn_pass=$(python3 "$PYTHON_OTP_PATH" vpn)
echo "$vpn_pass"

vpn_cmd='expect -c "
    spawn openvpn3 session-start --config '"$VPN_CONFIG"'
    expect \"*Auth User name:\"
    send -- \"'"$VPN_USERNAME"'\r\"
    expect \"Auth Password:\"
    send -- \"'"$VPN_PASSWORD"'\r\"
    expect \"Enter Authenticator Code:\"
    send -- \"'"$vpn_pass"'\r\"
    interact
"'

echo "--------------> login vpn <--------------"
eval "$vpn_cmd"
