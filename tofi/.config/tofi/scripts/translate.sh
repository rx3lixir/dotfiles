#!/bin/bash

# Colors for better readability
BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RED='\033[1;31m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Clear screen and show header
clear

# Default direction
direction="ru:en"
direction_text="Russian → English"

while true; do
    echo -e "${YELLOW}Current mode:${NC} ${GREEN}${direction_text}${NC}"
    echo ""
    echo -e "${CYAN}Commands:${NC}"
    echo ""
    echo -e "  ${YELLOW}:s${NC} - Switch translation direction"
    echo -e "  ${YELLOW}:c${NC} - Clear screen"
    echo -e "  ${YELLOW}:q${NC} - Quit"
    echo ""
    echo -e "${GREEN}Enter text to translate:${NC}"
    read -p "> " input
    
    # Handle commands
    if [[ "$input" == ":q" ]]; then
        echo -e "\n${CYAN}Goodbye!${NC}\n"
        break
    elif [[ "$input" == ":s" ]]; then
        if [[ "$direction" == "ru:en" ]]; then
            direction="en:ru"
            direction_text="English → Russian"
        else
            direction="ru:en"
            direction_text="Russian → English"
        fi
        clear
        echo -e "${GREEN}✓ Switched to: ${direction_text}${NC}\n"
        continue
    elif [[ "$input" == ":c" ]]; then
        clear
        continue
    elif [[ -z "$input" ]]; then
        continue
    fi
    
    # Translate
    echo ""
    echo -e "${CYAN}Translation:${NC}"
    echo -e "${BOLD}"
    trans -brief "$direction" "$input" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Translation failed. Is translate-shell installed?${NC}"
    fi
    echo -e "${NC}"
    echo ""
done
