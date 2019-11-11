#!/bin/bash

NC='\033[0m'
GREEN="\033[0;32m"
YELLOW="\033[1;33m"

MARKEDLINE="######################################"
MARKEDTEXT1="######### AUTO UPDATE SCRIPT #########"
MARKEDTEXT2="######## AUTO UPDATE COMPLETE ########"

echo -e "\n"$YELLOW$MARKEDLINE
echo -e $MARKEDTEXT1
echo -e $MARKEDLINE$NC


echo -e "\n${YELLOW}Updating package list...${NC}"
sudo apt update
echo -e "${GREEN}Update Complete!${NC}"

echo -e "\n${YELLOW}Installing updates...${NC}"
sudo apt upgrade -y
echo -e "${GREEN}Installation Complete!${NC}"

echo -e "\n${YELLOW}Removing non updated packages...${NC}"
sudo apt upgrade autoremove
echo -e "${GREEN}Non updated package removal complete!${NC}"

echo -e "\n${YELLOW}Cleaning up...${NC}"
sudo apt clean
echo -e "${GREEN}Clean up Complete!${NC}"

echo -e "\n"$GREEN$MARKEDLINE
echo -e $MARKEDTEXT2
echo -e $MARKEDLINE"\n"$NC
