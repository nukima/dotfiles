import os
import pyotp
import sys
from dotenv import load_dotenv

load_dotenv()

def getVPNCode(secret_type):
    secrets = {
        'vpn': os.getenv('VPN_SECRET'),
        'teleport': os.getenv('TELEPORT_SECRET'),
        'vpn_dev': os.getenv('VPN_DEV_SECRET')
    }
    
    if secret_type not in secrets:
        print(f"Error: Unknown secret type '{secret_type}'")
        sys.exit(1)
    
    if not secrets[secret_type]:
        print(f"Error: Secret for '{secret_type}' not found in environment variables")
        sys.exit(1)
    otp = pyotp.TOTP(secrets[secret_type]).now()
    print(otp)
    return otp

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Error: Please provide a secret type (vpn, teleport, or vpn_dev)")
        sys.exit(1)
        
    secret_type = sys.argv[1]
    getVPNCode(secret_type)
    sys.exit(0)