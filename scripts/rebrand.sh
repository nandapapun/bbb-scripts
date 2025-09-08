#!/bin/bash

set -e

echo "=== Starting restore-all-in-one.sh ==="

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Paths (these .txt and .env files are in the same directory as the script)
SETTINGS_FILE="$SCRIPT_DIR/Settings.txt"
CHANGE_FILE="$SCRIPT_DIR/Change.txt"
ENV_FILE="$SCRIPT_DIR/.env"

# Target files (user must set these)
TARGET_SETTINGS_YML="${1:-/workspaces/bbb-scripts/temp/settings.yml}"
TARGET_PROPERTIES="${2:-/workspaces/bbb-scripts/temp/bigbluebutton.properties}"

echo "Using:"
echo "  Settings file: $SETTINGS_FILE"
echo "  Change file:   $CHANGE_FILE"
echo "  Env file:      $ENV_FILE"
echo "  Target settings.yml: $TARGET_SETTINGS_YML"
echo "  Target properties:  $TARGET_PROPERTIES"

# Load environment variables
echo "Loading environment variables from $ENV_FILE..."
set -a
source "$ENV_FILE"
set +a

echo "Step 1: Restoring Settings to $TARGET_SETTINGS_YML..."

# Ensure Settings.txt ends with a newline so last line is processed
if [ -n "$(tail -c1 "$SETTINGS_FILE")" ]; then
  echo "" >> "$SETTINGS_FILE"
fi

# Hardcoded branding changes using .env variables
echo "Hardcoding branding lines..."
yq -i -y ".public.app.appName = \"$BRANDNAME\"" "$TARGET_SETTINGS_YML"
echo "Updated: public.app.appName to $BRANDNAME"
yq -i -y ".public.app.clientTitle = \"$BRANDNAME\"" "$TARGET_SETTINGS_YML"
echo "Updated: public.app.clientTitle to $BRANDNAME"
yq -i -y ".public.app.copyright = \"$POWEREDBYNAME ©2022\"" "$TARGET_SETTINGS_YML"
echo "Updated: public.app.copyright to $POWEREDBYNAME ©2022"
yq -i -y ".public.app.helpLink = \"$HELPURL\"" "$TARGET_SETTINGS_YML"
echo "Updated: public.app.helpLink to $HELPURL"

# Loop for the rest of the changes from Settings.txt (skip hardcoded keys)
while read -r line; do
  [[ -z "$line" || "$line" =~ ^# ]] && continue

  path="${line%%=*}"
  value="${line#*=}"

  # Skip hardcoded keys
  case "$path" in
    public.app.appName|public.app.clientTitle|public.app.copyright|public.app.helpLink)
      continue
      ;;
  esac

  echo "Updating: $path to $value"

  # Detect booleans and numbers, avoid quotes
  if [[ "$value" =~ ^(true|false)$ ]]; then
    yq -i -y ".${path} = ${value}" "$TARGET_SETTINGS_YML"
  elif [[ "$value" =~ ^[0-9]+$ ]]; then
    yq -i -y ".${path} = ${value}" "$TARGET_SETTINGS_YML"
  else
    yq -i -y ".${path} = \"${value}\"" "$TARGET_SETTINGS_YML"
  fi
done < "$SETTINGS_FILE"

echo "Step 1: Settings restored successfully."

echo "Step 2: Restoring Properties to $TARGET_PROPERTIES..."

# Apply replacements from Change.txt (tab or space separated)
while read -r line; do
  [[ -z "$line" || "$line" =~ ^# ]] && continue

  prop_name="${line%%=*}"
  replacement="$line"

  sed -i "s|^${prop_name}=.*|$replacement|" "$TARGET_PROPERTIES"
  echo "Updated: $prop_name in $TARGET_PROPERTIES"
done < "$CHANGE_FILE"

# Apply complex replacements using variables
sed -i "s|^defaultWelcomeMessage=.*|defaultWelcomeMessage=Welcome to <b>%%CONFNAME%%</b>!|" "$TARGET_PROPERTIES"
echo "Updated: defaultWelcomeMessage"
sed -i "s|^defaultWelcomeMessageFooter=.*|defaultWelcomeMessageFooter=Powered by <a href=\"$POWEREDBYURL\" target=\"_blank\"><u>$POWEREDBYNAME</u></a>.|" "$TARGET_PROPERTIES"
echo "Updated: defaultWelcomeMessageFooter"

echo "Step 2: Properties restored successfully."

echo "=== All steps completed successfully! ==="