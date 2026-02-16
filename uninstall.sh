#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Uninstalling viewmon...${NC}\n"

if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (sudo)${NC}"
    exit 1
fi

if [ -f /usr/local/bin/viewmon ]; then
    rm /usr/local/bin/viewmon
    echo -e "${GREEN}✓ viewmon removed successfully${NC}"
else
    echo -e "${YELLOW}viewmon not found${NC}"
fi

echo -e "\n${GREEN}Uninstallation complete!${NC}"
