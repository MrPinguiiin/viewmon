#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Box drawing characters
TOP_LEFT="╔"
TOP_RIGHT="╗"
BOTTOM_LEFT="╚"
BOTTOM_RIGHT="╝"
HORIZONTAL="═"
VERTICAL="║"
T_DOWN="╦"
T_UP="╩"
T_RIGHT="╠"
T_LEFT="╣"
CROSS="╬"

# Function to print header
print_header() {
    clear
    local width=80
    echo -e "${CYAN}${TOP_LEFT}$(printf '%*s' $((width-2)) '' | tr ' ' "${HORIZONTAL}")${TOP_RIGHT}${NC}"
    echo -e "${CYAN}${VERTICAL}${BOLD}${WHITE}$(printf '%*s' $(((width + ${#1})/2)) "$1")$(printf '%*s' $(((width - ${#1})/2 - 2)) '')${NC}${CYAN}${VERTICAL}${NC}"
    echo -e "${CYAN}${VERTICAL}${NC}    Hostname: ${GREEN}$(hostname)${NC} $(printf '%*s' $((width - 18 - ${#HOSTNAME})) '')${CYAN}${VERTICAL}${NC}"
    echo -e "${CYAN}${VERTICAL}${NC}    Time: ${GREEN}$(date '+%Y-%m-%d %H:%M:%S')${NC} $(printf '%*s' $((width - 38)) '')${CYAN}${VERTICAL}${NC}"
    echo -e "${CYAN}${VERTICAL}${NC}    Uptime: ${GREEN}$(uptime -p | sed 's/up //')${NC}$(printf '%*s' $((width - 17 - $(uptime -p | sed 's/up //' | wc -c))) '')${CYAN}${VERTICAL}${NC}"
    echo -e "${CYAN}${BOTTOM_LEFT}$(printf '%*s' $((width-2)) '' | tr ' ' "${HORIZONTAL}")${BOTTOM_RIGHT}${NC}\n"
}

# Function to create progress bar
progress_bar() {
    local percent=$1
    local width=40
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    # Color based on percentage
    local color=$GREEN
    if [ $percent -gt 80 ]; then
        color=$RED
    elif [ $percent -gt 60 ]; then
        color=$YELLOW
    fi
    
    printf "${color}["
    printf '%*s' $filled '' | tr ' ' '█'
    printf '%*s' $empty '' | tr ' ' '░'
    printf "]${NC} ${BOLD}%3d%%${NC}" $percent
}

# Function to get CPU usage
get_cpu_info() {
    echo -e "${YELLOW}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│${NC} ${BOLD}${WHITE}CPU INFORMATION${NC}$(printf '%*s' 60 '')${YELLOW}│${NC}"
    echo -e "${YELLOW}├─────────────────────────────────────────────────────────────────────────────┤${NC}"
    
    # CPU Model
    local cpu_model=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
    echo -e "${YELLOW}│${NC}  Model: ${CYAN}${cpu_model:0:60}${NC}$(printf '%*s' $((60 - ${#cpu_model})) '')${YELLOW}│${NC}"
    
    # CPU Cores
    local cpu_cores=$(nproc)
    echo -e "${YELLOW}│${NC}  Cores: ${CYAN}$cpu_cores${NC}$(printf '%*s' 67 '')${YELLOW}│${NC}"
    
    # CPU Usage
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    cpu_usage=${cpu_usage%.*}
    echo -e "${YELLOW}│${NC}  Usage: $(progress_bar $cpu_usage)$(printf '%*s' 25 '')${YELLOW}│${NC}"
    
    # Load Average
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | xargs)
    echo -e "${YELLOW}│${NC}  Load Average: ${CYAN}${load_avg}${NC}$(printf '%*s' $((54 - ${#load_avg})) '')${YELLOW}│${NC}"
    
    echo -e "${YELLOW}└─────────────────────────────────────────────────────────────────────────────┘${NC}\n"
}

# Function to get Memory usage
get_memory_info() {
    echo -e "${BLUE}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${BOLD}${WHITE}MEMORY INFORMATION${NC}$(printf '%*s' 57 '')${BLUE}│${NC}"
    echo -e "${BLUE}├─────────────────────────────────────────────────────────────────────────────┤${NC}"
    
    # RAM Usage
    local total_mem=$(free -m | awk '/Mem:/ {print $2}')
    local used_mem=$(free -m | awk '/Mem:/ {print $3}')
    local mem_percent=$(awk "BEGIN {printf \"%.0f\", ($used_mem/$total_mem)*100}")
    
    echo -e "${BLUE}│${NC}  RAM: ${used_mem}MB / ${total_mem}MB${NC}$(printf '%*s' $((58 - ${#used_mem} - ${#total_mem})) '')${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  $(progress_bar $mem_percent)$(printf '%*s' 30 '')${BLUE}│${NC}"
    
    # Swap Usage
    local total_swap=$(free -m | awk '/Swap:/ {print $2}')
    local used_swap=$(free -m | awk '/Swap:/ {print $3}')
    
    if [ $total_swap -gt 0 ]; then
        local swap_percent=$(awk "BEGIN {printf \"%.0f\", ($used_swap/$total_swap)*100}")
        echo -e "${BLUE}│${NC}  SWAP: ${used_swap}MB / ${total_swap}MB${NC}$(printf '%*s' $((56 - ${#used_swap} - ${#total_swap})) '')${BLUE}│${NC}"
        echo -e "${BLUE}│${NC}  $(progress_bar $swap_percent)$(printf '%*s' 30 '')${BLUE}│${NC}"
    else
        echo -e "${BLUE}│${NC}  SWAP: ${CYAN}Not configured${NC}$(printf '%*s' 54 '')${BLUE}│${NC}"
    fi
    
    echo -e "${BLUE}└─────────────────────────────────────────────────────────────────────────────┘${NC}\n"
}

# Function to get Disk usage
get_disk_info() {
    echo -e "${PURPLE}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${PURPLE}│${NC} ${BOLD}${WHITE}DISK USAGE${NC}$(printf '%*s' 65 '')${PURPLE}│${NC}"
    echo -e "${PURPLE}├─────────────────────────────────────────────────────────────────────────────┤${NC}"
    
    # Get all mounted filesystems
    while IFS= read -r line; do
        local filesystem=$(echo $line | awk '{print $1}')
        local size=$(echo $line | awk '{print $2}')
        local used=$(echo $line | awk '{print $3}')
        local avail=$(echo $line | awk '{print $4}')
        local percent=$(echo $line | awk '{print $5}' | tr -d '%')
        local mount=$(echo $line | awk '{print $6}')
        
        # Skip if mount point is too weird
        if [[ ! $mount =~ ^/|^/boot|^/home ]]; then
            continue
        fi
        
        echo -e "${PURPLE}│${NC}  ${CYAN}${mount}${NC} (${filesystem})$(printf '%*s' $((60 - ${#mount} - ${#filesystem})) '')${PURPLE}│${NC}"
        echo -e "${PURPLE}│${NC}    ${used} / ${size} (${avail} free)$(printf '%*s' $((56 - ${#used} - ${#size} - ${#avail})) '')${PURPLE}│${NC}"
        echo -e "${PURPLE}│${NC}    $(progress_bar $percent)$(printf '%*s' 28 '')${PURPLE}│${NC}"
    done < <(df -h | grep -E '^/dev/' | head -5)
    
    echo -e "${PURPLE}└─────────────────────────────────────────────────────────────────────────────┘${NC}\n"
}

# Function to get Network info
get_network_info() {
    echo -e "${GREEN}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${GREEN}│${NC} ${BOLD}${WHITE}NETWORK INFORMATION${NC}$(printf '%*s' 56 '')${GREEN}│${NC}"
    echo -e "${GREEN}├─────────────────────────────────────────────────────────────────────────────┤${NC}"
    
    # Get network interfaces
    local interfaces=$(ip -o link show | awk -F': ' '{print $2}' | grep -v 'lo')
    
    for iface in $interfaces; do
        local ip_addr=$(ip -4 addr show $iface 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
        
        if [ ! -z "$ip_addr" ]; then
            local rx_bytes=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null)
            local tx_bytes=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null)
            
            # Convert to MB
            local rx_mb=$(awk "BEGIN {printf \"%.2f\", $rx_bytes/1024/1024}")
            local tx_mb=$(awk "BEGIN {printf \"%.2f\", $tx_bytes/1024/1024}")
            
            echo -e "${GREEN}│${NC}  Interface: ${CYAN}${iface}${NC}$(printf '%*s' $((64 - ${#iface})) '')${GREEN}│${NC}"
            echo -e "${GREEN}│${NC}    IP: ${ip_addr}$(printf '%*s' $((66 - ${#ip_addr})) '')${GREEN}│${NC}"
            echo -e "${GREEN}│${NC}    RX: ${rx_mb} MB  |  TX: ${tx_mb} MB$(printf '%*s' $((48 - ${#rx_mb} - ${#tx_mb})) '')${GREEN}│${NC}"
        fi
    done
    
    # Active connections
    local connections=$(netstat -an 2>/dev/null | grep ESTABLISHED | wc -l)
    echo -e "${GREEN}│${NC}  Active Connections: ${CYAN}${connections}${NC}$(printf '%*s' $((54 - ${#connections})) '')${GREEN}│${NC}"
    
    echo -e "${GREEN}└─────────────────────────────────────────────────────────────────────────────┘${NC}\n"
}

# Function to get Top Processes
get_top_processes() {
    echo -e "${RED}┌─────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${RED}│${NC} ${BOLD}${WHITE}TOP PROCESSES (CPU)${NC}$(printf '%*s' 56 '')${RED}│${NC}"
    echo -e "${RED}├─────────────────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${RED}│${NC}  ${BOLD}PID      USER       CPU%%    MEM%%    COMMAND${NC}$(printf '%*s' 31 '')${RED}│${NC}"
    echo -e "${RED}├─────────────────────────────────────────────────────────────────────────────┤${NC}"
    
    ps aux --sort=-%cpu | head -6 | tail -5 | while read line; do
        local user=$(echo $line | awk '{print $1}' | cut -c1-10)
        local pid=$(echo $line | awk '{print $2}')
        local cpu=$(echo $line | awk '{print $3}')
        local mem=$(echo $line | awk '{print $4}')
        local cmd=$(echo $line | awk '{print $11}' | cut -c1-20)
        
        printf "${RED}│${NC}  %-8s %-10s %-8s %-8s %-20s" "$pid" "$user" "$cpu" "$mem" "$cmd"
        printf "$(printf '%*s' $((22 - ${#cmd})) '')${RED}│${NC}\n"
    done
    
    echo -e "${RED}└─────────────────────────────────────────────────────────────────────────────┘${NC}\n"
}

# Main execution
print_header "SYSTEM MONITORING DASHBOARD"
get_cpu_info
get_memory_info
get_disk_info
get_network_info
get_top_processes

echo -e "${CYAN}${BOLD}Press any key to refresh or Ctrl+C to exit${NC}"
