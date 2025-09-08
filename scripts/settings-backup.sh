#!/bin/bash
# filepath: /workspaces/bbb-scripts/scripts/restore-settings.sh

TARGET="/workspaces/bbb-scripts/temp/settings.yml"
SETTINGS_FILE="/workspaces/bbb-scripts/scripts/Settings.txt"

while read -r line; do
  [[ -z "$line" || "$line" =~ ^# ]] && continue
  path="${line%%=*}"
  value="${line#*=}"

  # Debug output
  echo "Updating: $path to $value"

  if [[ "$value" =~ ^(true|false)$ ]]; then
    yq -i -y ".${path} = ${value}" "$TARGET"
  elif [[ "$value" =~ ^[0-9]+$ ]]; then
    yq -i -y ".${path} = ${value}" "$TARGET"
  else
    yq -i -y ".${path} = \"${value}\"" "$TARGET"
  fi
done < "$SETTINGS_FILE"

echo "Settings updated in $TARGET"