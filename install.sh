#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  System Monitor Installation  ${NC}"
echo -e "${BLUE}================================${NC}\n"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (sudo)${NC}"
    exit 1
fi

# Install dependencies
echo -e "${YELLOW}[1/4] Installing dependencies...${NC}"
apt-get update -qq
apt-get install -y bc sysstat net-tools > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Dependencies installed${NC}\n"
else
    echo -e "${RED}✗ Failed to install dependencies${NC}"
    exit 1
fi

# Copy monitoring script to /usr/local/bin
echo -e "${YELLOW}[2/4] Installing monitoring script...${NC}"

# If viewmon.sh doesn't exist locally, download it
if [ ! -f "viewmon.sh" ]; then
    echo -e "${YELLOW}viewmon.sh not found locally, downloading from repository...${NC}"
    wget -qO viewmon.sh https://raw.githubusercontent.com/MrPinguiiin/viewmon/main/viewmon.sh
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Failed to download viewmon.sh${NC}"
        exit 1
    fi
fi

cp viewmon.sh /usr/local/bin/viewmon
chmod +x /usr/local/bin/viewmon

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Script installed to /usr/local/bin/viewmon${NC}\n"
else
    echo -e "${RED}✗ Failed to install script${NC}"
    exit 1
fi

# Make it executable globally
echo -e "${YELLOW}[3/4] Setting permissions...${NC}"
chmod 755 /usr/local/bin/viewmon
echo -e "${GREEN}✓ Permissions set${NC}\n"

# Create update script
echo -e "${YELLOW}[4/5] Installing update command...${NC}"
cat << 'EOF' > /usr/local/bin/viewmon-update
#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Updating ViewMon...${NC}"
wget -qO /tmp/install.sh https://raw.githubusercontent.com/MrPinguiiin/viewmon/main/install.sh
if [ $? -eq 0 ]; then
    sudo bash /tmp/install.sh
    echo -e "${GREEN}✓ ViewMon updated successfully!${NC}"
else
    echo -e "${RED}✗ Failed to download update${NC}"
fi
rm -f /tmp/install.sh
EOF
chmod +x /usr/local/bin/viewmon-update
echo -e "${GREEN}✓ Update command installed to /usr/local/bin/viewmon-update${NC}\n"

# Verify installation
echo -e "${YELLOW}[5/5] Verifying installation...${NC}"
if command -v viewmon &> /dev/null; then
    echo -e "${GREEN}✓ Installation successful!${NC}\n"
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}Installation Complete!${NC}"
    echo -e "${GREEN}================================${NC}\n"
    echo -e "You can now run: ${BLUE}viewmon${NC}"
    echo -e "To update later, run: ${BLUE}viewmon-update${NC}\n"
else
    echo -e "${RED}✗ Installation verification failed${NC}"
    exit 1
fi
