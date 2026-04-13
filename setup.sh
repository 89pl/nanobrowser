#!/usr/bin/env bash
#
# Nanobrowser - Quick Setup & Build Script
#
# This script checks prerequisites and builds the Chrome extension.
# After building, load the dist/ folder in chrome://extensions/
#
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Nanobrowser - Extension Build Script${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# ---- Check if dist/manifest.json already exists ----
if [ -f "dist/manifest.json" ]; then
  echo -e "${GREEN}A pre-built extension already exists in the dist/ folder.${NC}"
  echo ""
  echo "You can load it right now:"
  echo "  1. Open chrome://extensions/"
  echo "  2. Enable Developer mode (top right)"
  echo "  3. Click 'Load unpacked'"
  echo "  4. Select the 'dist' folder inside this repository"
  echo ""
  read -p "Do you want to rebuild anyway? (y/N) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Done! Load the dist/ folder in Chrome to use Nanobrowser.${NC}"
    exit 0
  fi
  echo ""
fi

# ---- Check Node.js ----
echo -e "${BLUE}Checking prerequisites...${NC}"
echo ""

if ! command -v node &> /dev/null; then
  echo -e "${RED}Node.js is not installed.${NC}"
  echo "Please install Node.js v22.12.0 or higher: https://nodejs.org/"
  exit 1
fi

NODE_VERSION=$(node -v | sed 's/v//')
NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
if [ "$NODE_MAJOR" -lt 22 ]; then
  echo -e "${YELLOW}Warning: Node.js $NODE_VERSION detected, but v22.12.0+ is recommended.${NC}"
  echo "The build may fail. Install Node.js v22.12.0+: https://nodejs.org/"
  echo ""
fi
echo -e "  Node.js: ${GREEN}v${NODE_VERSION}${NC}"

# ---- Check pnpm ----
if ! command -v pnpm &> /dev/null; then
  echo -e "${YELLOW}pnpm is not installed. Installing it now...${NC}"
  npm install -g pnpm@9.15.1
fi

PNPM_VERSION=$(pnpm --version)
echo -e "  pnpm:    ${GREEN}v${PNPM_VERSION}${NC}"
echo ""

# ---- Install dependencies ----
echo -e "${BLUE}Installing dependencies...${NC}"
pnpm install
echo ""

# ---- Build the extension ----
echo -e "${BLUE}Building the extension...${NC}"
pnpm build
echo ""

# ---- Verify build ----
if [ ! -f "dist/manifest.json" ]; then
  echo -e "${RED}Build failed! dist/manifest.json was not generated.${NC}"
  echo "Please check the build output above for errors."
  exit 1
fi

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  Build successful!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "The extension has been built to the 'dist/' folder."
echo ""
echo "To load in Chrome:"
echo "  1. Open chrome://extensions/"
echo "  2. Enable Developer mode (toggle in top right)"
echo "  3. Click 'Load unpacked'"
echo -e "  4. Select: ${BLUE}$(pwd)/dist${NC}"
echo ""
echo -e "${GREEN}Done!${NC}"
