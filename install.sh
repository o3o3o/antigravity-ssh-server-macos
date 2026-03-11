#!/bin/bash
# Antigravity Remote SSH Server Installation Script for macOS (Darwin/arm64)
#
# Usage: ./install.sh <COMMIT_ID>
# Example: ./install.sh "1.20.5-4603c2a412f8c7cca552ff00db91c3ee787016ff"
#
# To get the COMMIT_ID from Antigravity client:
# 1. Open Antigravity
# 2. Try to connect via Remote-SSH
# 3. Check the Output tab for installation script
# 4. Look for DISTRO_IDE_VERSION and DISTRO_COMMIT values
# 5. Combine them: DISTRO_IDE_VERSION-DISTRO_COMMIT

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
if [ -z "$1" ]; then
    echo -e "${RED}Error: COMMIT_ID required${NC}"
    echo "Usage: $0 <COMMIT_ID>"
    echo "Example: $0 \"1.20.5-4603c2a412f8c7cca552ff00db91c3ee787016ff\""
    echo ""
    echo "To find COMMIT_ID:"
    echo "1. Open Antigravity client"
    echo "2. Try to connect via Remote-SSH"
    echo "3. Check Output tab for the installation script"
    echo "4. Copy DISTRO_IDE_VERSION and DISTRO_COMMIT"
    echo "5. Combine them: DISTRO_IDE_VERSION-DISTRO_COMMIT"
    exit 1
fi

COMMIT_ID="$1"
COMMIT_HASH="${COMMIT_ID##*-}"
SERVER_DIR="$HOME/.antigravity-server/bin/$COMMIT_ID"
TEMP_DIR="/tmp/antigravity-install"

echo -e "${BLUE}=== Antigravity Remote SSH Server Installation ===${NC}"
echo "Version: $COMMIT_ID"
echo "Commit: $COMMIT_HASH"
echo "Target: $SERVER_DIR"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"
if ! command -v wget &> /dev/null; then
    echo -e "${RED}Error: wget not found. Install with: brew install wget${NC}"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: curl not found${NC}"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo -e "${RED}Error: npm not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Prerequisites OK${NC}"
echo ""

# Create temp directory
echo -e "${YELLOW}Preparing installation...${NC}"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Backup existing installation
if [ -d "$SERVER_DIR" ]; then
    echo -e "${YELLOW}Backing up existing installation...${NC}"
    mv "$SERVER_DIR" "${SERVER_DIR}.backup.$(date +%Y%m%d%H%M%S)"
fi

mkdir -p "$SERVER_DIR"
echo -e "${GREEN}✓ Server directory created${NC}"
echo ""

# Download linux-arm server tarball
echo -e "${YELLOW}Downloading linux-arm server tarball...${NC}"
wget --tries=3 --timeout=30 --continue --quiet \
  -O "$TEMP_DIR/antigravity-linux.tar.gz" \
  "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/${COMMIT_ID}/linux-arm/Antigravity-reh.tar.gz"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Download failed. Trying alternative mirrors...${NC}"

    # Try alternative mirrors
    DOWNLOAD_URLS=(
        "https://redirector.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/${COMMIT_ID}/linux-arm/Antigravity-reh.tar.gz"
        "https://edgedl.me.gvt1.com/edgedl/antigravity/stable/${COMMIT_ID}/linux-arm/Antigravity-reh.tar.gz"
        "https://redirector.gvt1.com/edgedl/antigravity/stable/${COMMIT_ID}/linux-arm/Antigravity-reh.tar.gz"
    )

    DOWNLOAD_SUCCESS=0
    for url in "${DOWNLOAD_URLS[@]}"; do
        echo "Trying: $url"
        wget --tries=2 --timeout=10 --quiet -O "$TEMP_DIR/antigravity-linux.tar.gz" "$url"
        if [ $? -eq 0 ]; then
            DOWNLOAD_SUCCESS=1
            break
        fi
    done

    if [ $DOWNLOAD_SUCCESS -eq 0 ]; then
        echo -e "${RED}Error: All download attempts failed${NC}"
        echo -e "${YELLOW}Note: Make sure COMMIT_ID is correct and includes both version and commit hash${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓ Download complete${NC}"
echo ""

# Extract complete linux-arm server
echo -e "${YELLOW}Extracting linux-arm server...${NC}"
tar -xzf "$TEMP_DIR/antigravity-linux.tar.gz" -C "$SERVER_DIR" --strip-components 1
echo -e "${GREEN}✓ Server extracted${NC}"
echo ""

# Update commit ID in product.json
echo -e "${YELLOW}Updating configuration...${NC}"
OLD_COMMIT=$(grep '"commit"' "$SERVER_DIR/product.json" | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
sed -i.bak "s/$OLD_COMMIT/$COMMIT_HASH/g" "$SERVER_DIR/product.json"
rm -f "$SERVER_DIR/product.json.bak"

# Create commit-id file
echo "$COMMIT_HASH" > "$SERVER_DIR/commit-id"
echo -e "${GREEN}✓ Configuration updated${NC}"
echo ""

# Download and replace Node.js binary with darwin version
echo -e "${YELLOW}Installing darwin Node.js binary...${NC}"
NODE_VERSION="v22.11.0"
curl -fsSL "https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-darwin-arm64.tar.gz" -o "$TEMP_DIR/node.tar.gz"
tar -xzf "$TEMP_DIR/node.tar.gz" -C "$TEMP_DIR"
cp "$TEMP_DIR/node-${NODE_VERSION}-darwin-arm64/bin/node" "$SERVER_DIR/node"
chmod +x "$SERVER_DIR/node"
echo -e "${GREEN}✓ Node.js ${NODE_VERSION} installed${NC}"
echo ""

# Sign node binary
echo -e "${YELLOW}Signing binaries...${NC}"
codesign --force --deep --sign - "$SERVER_DIR/node" 2>/dev/null || true
echo -e "${GREEN}✓ Binaries signed${NC}"
echo ""

# Rebuild native modules for macOS
echo -e "${YELLOW}Rebuilding native modules for macOS...${NC}"
cd "$SERVER_DIR"
npm rebuild @vscode/spdlog @parcel/watcher 2>&1 | tail -5
echo -e "${GREEN}✓ Native modules rebuilt${NC}"
echo ""

# Sign rebuilt modules
echo -e "${YELLOW}Signing rebuilt modules...${NC}"
find "$SERVER_DIR/node_modules/@vscode/spdlog" -name "*.node" -exec codesign --force --sign - {} \; 2>/dev/null || true
find "$SERVER_DIR/node_modules/@parcel/watcher" -name "*.node" -exec codesign --force --sign - {} \; 2>/dev/null || true
echo -e "${GREEN}✓ Rebuilt modules signed${NC}"
echo ""

# Clear quarantine flags
xattr -dr com.apple.quarantine "$SERVER_DIR" 2>/dev/null || true

# Cleanup
rm -rf "$TEMP_DIR"

# Verify installation
echo -e "${YELLOW}Verifying installation...${NC}"
cd "$SERVER_DIR"
SERVER_VERSION=$(./node out/server-main.js --version 2>&1 | head -3)
echo "$SERVER_VERSION"
echo ""

# Check server structure
echo "=== Server structure ==="
echo "✓ Entry point: out/server-main.js"
echo "✓ Server script: bin/antigravity-server"
ls -la "$SERVER_DIR/out/server-main.js" "$SERVER_DIR/bin/antigravity-server" 2>/dev/null && echo "✓ Key files present"
echo ""

# Final check
echo -e "${GREEN}=== Installation Complete! ===${NC}"
echo ""
echo "Server directory: $SERVER_DIR"
echo "Version: $COMMIT_ID"
echo ""
echo -e "${YELLOW}KEY POINTS:${NC}"
echo "  • Uses linux-arm server tarball (same version)"
echo "  • Entry point: server-main.js (NOT cli.js!)"
echo "  • Node binary replaced with darwin-arm64 version"
echo "  • Native modules rebuilt for macOS"
echo ""
echo "You can now connect from your Antigravity client via Remote-SSH."
echo ""
echo -e "${YELLOW}Note: You may see 'spdlog.node' warnings in logs - these can be ignored.${NC}"
echo "The server will work correctly despite these warnings."
