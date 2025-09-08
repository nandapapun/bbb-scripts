#!/bin/bash

set -e

echo "=== Starting restore-all.sh ==="

# Paths
SETTINGS_SCRIPT="/workspaces/bbb-scripts/scripts/restore-settings.sh"
PROPERTIES_SCRIPT="/workspaces/bbb-scripts/scripts/restore-properties.sh"

# Step 1: Restore Settings
echo "Step 1: Restoring Settings from $SETTINGS_SCRIPT..."
if [ ! -f "$SETTINGS_SCRIPT" ]; then
  echo "ERROR: $SETTINGS_SCRIPT not found!"
  exit 1
fi

bash "$SETTINGS_SCRIPT"
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to restore settings!"
  exit 2
fi
echo "Step 1: Settings restored successfully."

# Step 2: Restore Properties
echo "Step 2: Restoring Properties from $PROPERTIES_SCRIPT..."
if [ ! -f "$PROPERTIES_SCRIPT" ]; then
  echo "ERROR: $PROPERTIES_SCRIPT not found!"
  exit 3
fi

bash "$PROPERTIES_SCRIPT"
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to restore properties!"
  exit 4
fi
echo "Step 2: Properties restored successfully."

echo "=== All steps completed successfully! ==="