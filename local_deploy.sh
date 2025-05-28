#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the addon name from the current directory
ADDON_NAME=$(basename "$PWD")

echo -e "${YELLOW}Deploying $ADDON_NAME to local WoW installation...${NC}"

# Common WoW installation paths for macOS
WOW_PATHS=(
    "/Applications/World of Warcraft/_retail_/Interface/AddOns"
    "$HOME/Applications/World of Warcraft/_retail_/Interface/AddOns"
    "/Applications/Battle.net/World of Warcraft/_retail_/Interface/AddOns"
)

# Find the WoW installation
ADDON_PATH=""
for path in "${WOW_PATHS[@]}"; do
    if [ -d "$(dirname "$(dirname "$path")")" ]; then
        ADDON_PATH="$path"
        break
    fi
done

if [ -z "$ADDON_PATH" ]; then
    echo -e "${RED}Error: Could not find WoW installation${NC}"
    echo "Please make sure World of Warcraft is installed in one of these locations:"
    for path in "${WOW_PATHS[@]}"; do
        echo "  - $(dirname "$(dirname "$path")")"
    done
    exit 1
fi

# Create target directory if it doesn't exist
TARGET_DIR="$ADDON_PATH/$ADDON_NAME"
mkdir -p "$TARGET_DIR"

# Copy files
echo "Copying files to: $TARGET_DIR"
cp -r ./* "$TARGET_DIR/" 2>/dev/null

# Remove the deployment script from the target
rm -f "$TARGET_DIR/local_deploy.sh"
rm -f "$TARGET_DIR/local_deploy.ps1"

echo -e "${GREEN}✓ $ADDON_NAME deployed successfully!${NC}"
echo -e "${YELLOW}Remember to reload your UI in-game with /reload${NC}"