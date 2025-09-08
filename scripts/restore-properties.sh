#!/bin/bash

TARGET="/workspaces/bbb-scripts/temp/bigbluebutton.properties"
CHANGE_FILE="/workspaces/bbb-scripts/scripts/Change.txt"
ENV_FILE="/workspaces/bbb-scripts/scripts/.env"

# Load environment variables
set -a
source "$ENV_FILE"
set +a

# Apply replacements from Change.txt (tab or space separated)
while read -r line; do
  # Skip empty lines and comments
  [[ -z "$line" || "$line" =~ ^# ]] && continue

  # Extract property name (before '=')
  prop_name="${line%%=*}"
  # Full replacement line
  replacement="$line"

  # Replace any line starting with 'prop_name='
  sed -i "s|^${prop_name}=.*|$replacement|" "$TARGET"
done < "$CHANGE_FILE"

# Apply complex replacements using variables
sed -i "s|^defaultWelcomeMessage=.*|defaultWelcomeMessage=Welcome to <b>%%CONFNAME%%</b>!|" "$TARGET"
sed -i "s|^defaultWelcomeMessageFooter=.*|defaultWelcomeMessageFooter=Powered by <a href=\"$POWEREDBYURL\" target=\"_blank\"><u>$POWEREDBYNAME</u></a>.|" "$TARGET"

echo "Rebranding complete for $TARGET"