#!/bin/bash

# ==============================================================================
#  Restore SSH Keys Script (from direct text)
#
#  This script restores SSH keys by writing them directly from variables
#  into the user's .ssh folder. It creates the .ssh directory if it
#  doesn't exist and sets the correct, secure file permissions.
# ==============================================================================

# --- Configuration ---
# IMPORTANT: Paste your private and public key content below.
# Make sure to paste the ENTIRE key, including the start and end lines.

PRIVATE_KEY_CONTENT="-----BEGIN OPENSSH PRIVATE KEY-----
PASTE YOUR PRIVATE KEY CONTENT HERE
THIS IS JUST A PLACEHOLDER
-----END OPENSSH PRIVATE KEY-----"

PUBLIC_KEY_CONTENT="ssh-rsa PASTE_YOUR_PUBLIC_KEY_CONTENT_HERE user@hostname"

# The target SSH directory in the user's home folder.
SSH_DIR="$HOME/.ssh"

# --- Main Script Logic ---

# Friendly start message
echo "Hey there! Starting the SSH key restoration process from script..."
echo "------------------------------------------------------------------"

# Check if the user has actually pasted their keys
if [[ "$PRIVATE_KEY_CONTENT" == *"PASTE YOUR PRIVATE KEY"* || "$PUBLIC_KEY_CONTENT" == *"PASTE_YOUR_PUBLIC_KEY"* ]]; then
    echo "❌ Error: You haven't pasted your keys into the script yet."
    echo "Please edit the 'PRIVATE_KEY_CONTENT' and 'PUBLIC_KEY_CONTENT' variables."
    exit 1
fi

# Create the .ssh directory if it doesn't exist
if [ ! -d "$SSH_DIR" ]; then
    echo "🔧 The '$SSH_DIR' directory doesn't exist. Creating it now."
    mkdir -p "$SSH_DIR"
else
    echo "👍 The '$SSH_DIR' directory already exists."
fi

# Write the key content to the appropriate files
echo "📝 Writing keys to '$SSH_DIR'..."
echo "$PRIVATE_KEY_CONTENT" > "$SSH_DIR/id_rsa"
echo "$PUBLIC_KEY_CONTENT" > "$SSH_DIR/id_rsa.pub"
echo "   - Private and public keys created."


# Set the correct permissions - this is VERY important for SSH security
echo "🔒 Setting secure permissions..."

# The .ssh directory should only be accessible by you (read, write, execute)
chmod 700 "$SSH_DIR"
echo "   - Permissions for '$SSH_DIR' set to 700."

# Your private key should only be readable by you
chmod 600 "$SSH_DIR/id_rsa"
echo "   - Permissions for private key ('$SSH_DIR/id_rsa') set to 600."

# Your public key can be more permissive, but 644 is standard
chmod 644 "$SSH_DIR/id_rsa.pub"
echo "   - Permissions for public key ('$SSH_DIR/id_rsa.pub') set to 644."


echo ""
echo "✅ All done, bro! Your SSH keys have been created from the script and secured."
echo "You should be good to go!"

