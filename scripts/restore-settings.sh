#!/bin/bash
# filepath: /workspaces/bbb-scripts/scripts/restore-settings.sh

TARGET="/workspaces/bbb-scripts/temp/settings.yml"
SETTINGS_FILE="/workspaces/bbb-scripts/scripts/Settings.txt"
ENV_FILE="/workspaces/bbb-scripts/scripts/.env"

# Load environment variables
set -a
source "$ENV_FILE"
set +a

# Ensure Settings.txt ends with a newline so last line is processed
if [ -n "$(tail -c1 "$SETTINGS_FILE")" ]; then
  echo "" >> "$SETTINGS_FILE"
fi

# Hardcoded branding changes using .env variables
echo "Hardcoding branding lines..."
yq -i -y ".public.app.appName = \"$BRANDNAME\"" "$TARGET"
echo "Updated: public.app.appName to $BRANDNAME"
yq -i -y ".public.app.clientTitle = \"$BRANDNAME\"" "$TARGET"
echo "Updated: public.app.clientTitle to $BRANDNAME"
yq -i -y ".public.app.copyright = \"$POWEREDBYNAME ©2022\"" "$TARGET"
echo "Updated: public.app.copyright to $POWEREDBYNAME ©2022"
yq -i -y ".public.app.helpLink = \"$HELPURL\"" "$TARGET"
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

  # Debug output
  echo "Updating: $path to $value"

  # Detect booleans and numbers, avoid quotes
  if [[ "$value" =~ ^(true|false)$ ]]; then
    yq -i -y ".${path} = ${value}" "$TARGET"
  elif [[ "$value" =~ ^[0-9]+$ ]]; then
    yq -i -y ".${path} = ${value}" "$TARGET"
  else
    yq -i -y ".${path} = \"${value}\"" "$TARGET"
  fi
done < "$SETTINGS_FILE"

echo "Settings updated in $TARGET"