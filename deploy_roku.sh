#!/bin/zsh

# Set these variables for your environment
ROKU_IP="192.168.2.147"      # Change to your Roku device IP
ROKU_USER="rokudev"          # Default Roku dev username
ROKU_PASS="nadSMOKE3465"    # Your Roku dev password

PROJECT_DIR="TMDB"
ZIP_NAME="Archive.zip"

# Zip the project contents
cd "$PROJECT_DIR"
zip -r "$ZIP_NAME" . -x "*.DS_Store" "*.git*" "*.zip"
cd ..

# Deploy to Roku device
curl -u "$ROKU_USER:$ROKU_PASS" --digest -F "mysubmit=Install" -F "archive=@$PROJECT_DIR/$ZIP_NAME" "http://$ROKU_IP/plugin_install"

echo "Deployment complete."