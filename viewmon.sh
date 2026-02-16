#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Box drawing characters
HLINE="─"
VLINE="│"
TOP_LEFT="╭"
TOP_RIGHT="╮"
BOTTOM_LEFT="╰"
BOTTOM_RIGHT="╯"

# Terminal dimensions
get_terminal_size() {
    LINES=$(tput lines 2>/dev/null || echo 24)
    COLS=$(tput cols 2>/dev/null || echo 80)
}

# Progress bar function
progress_bar() {
    local percent=$1
    local width=30
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    local color=$GREEN
    if [ $percent -gt 80 ]; then
        color=$RED
    elif [ $percent -gt 60 ]; then
        color=$YELLOW
    fi
    
    printf "${color}"
    printf '█'%.0s $(seq 1 $filled 2>/dev/null)
    printf "${DIM}▒${NC}"
    printf '▒'%.0s $(seq 1 $empty 2>/dev/null)
    printf "${NC} ${BOLD}%3d%%${NC}" $percent
}

# Get CPU info
get_cpu_info() {
    local cpu_model=$(lscpu 2>/dev/null | grep "Model name" | cut -d':' -f2 | xargs)
    local cpu_cores=$(nproc 2>/dev/null || echo 1)
    local cpu_usage=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    cpu_usage=${cpu_usage%.*}

    local load_avg=$(uptime 2>/dev/null | awk -F'load average:' '{print $2}' | xargs)

    echo -e "${CYAN}${TOP_LEFT}${HLINE}┬─${WHITE} CPU INFORMATION ${NC}${CYAN}─────────────────────────────────────────────${TOP_RIGHT}"
    echo -e "${CYAN}${VLINE}${NC}  ${WHITE}Model:${NC}   ${cpu_model:0:50}"
    echo -e "${CYAN}${VLINE}${NC}  ${WHITE}Cores:${NC}   ${cpu_cores} Core(s)"
    echo -e "${CYAN}${VLINE}${NC}  ${WHITE}Usage:${NC}   $(progress_bar ${cpu_usage:-0})"
    echo -e "${CYAN}${VLINE}${NC}  ${WHITE}Load:${NC}    ${load_avg}"
    echo -e "${CYAN}${BOTTOM_LEFT}${HLINE}┴────────────────────────────────────────────────────────────${BOTTOM_RIGHT}"
}

# Get Memory info
get_memory_info() {
    local total_mem=$(free -m 2>/dev/null | awk '/Mem:/ {print $2}')
    local used_mem=$(free -m 2>/dev/null | awk '/Mem:/ {print $3}')
    local mem_percent=$(awk "BEGIN {printf \"%.0f\", ($used_mem/$total_mem)*100}" 2>/dev/null)

    local total_swap=$(free -m 2>/dev/null | awk '/Swap:/ {print $2}')
    local used_swap=$(free -m 2>/dev/null | awk '/Swap:/ {print $3}')

    echo -e "${BLUE}${TOP_LEFT}${HLINE}┬─${WHITE} MEMORY INFORMATION ${NC}${BLUE}──────────────────────────────────────${TOP_RIGHT}"
    echo -e "${BLUE}${VLINE}${NC}  ${WHITE}RAM:${NC}    ${used_mem:-0}MB / ${total_mem:-0}MB  "
    echo -e "${BLUE}${VLINE}${NC}         $(progress_bar ${mem_percent:-0})"

    if [ ${total_swap:-0} -gt 0 ]; then
        local swap_percent=$(awk "BEGIN {printf \"%.0f\", ($used_swap/$total_swap)*100}" 2>/dev/null)
        echo -e "${BLUE}${VLINE}${NC}  ${WHITE}Swap:${NC}   ${used_swap:-0}MB / ${total_swap:-0}MB  "
        echo -e "${BLUE}${VLINE}${NC}         $(progress_bar ${swap_percent:-0})"
    else
        echo -e "${BLUE}${VLINE}${NC}  ${WHITE}Swap:${NC}   Not configured"
    fi
    echo -e "${BLUE}${BOTTOM_LEFT}${HLINE}┴────────────────────────────────────────────────────────${BOTTOM_RIGHT}"
}

# Get Disk info
get_disk_info() {
    echo -e "${PURPLE}${TOP_LEFT}${HLINE}┬─${WHITE} DISK USAGE ${NC}${PURPLE}───────────────────────────────────────────────${TOP_RIGHT}"

    df -h 2>/dev/null | grep -E '^/dev/' | head -4 | while read line; do
        local mount=$(echo $line | awk '{print $6}')
        local size=$(echo $line | awk '{print $2}')
        local used=$(echo $line | awk '{print $3}')
        local avail=$(echo $line | awk '{print $4}')
        local percent=$(echo $line | awk '{print $5}' | tr -d '%')

        echo -e "${PURPLE}${VLINE}${NC}  ${WHITE}${mount}${NC}"
        echo -e "${PURPLE}${VLINE}${NC}    Used: ${used}  Free: ${avail}  "
        echo -e "${PURPLE}${VLINE}${NC}    $(progress_bar ${percent:-0})"
    done

    echo -e "${PURPLE}${BOTTOM_LEFT}${HLINE}┴────────────────────────────────────────────────────────────${BOTTOM_RIGHT}"
}

# Get Network info
get_network_info() {
    local interfaces=$(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -v 'lo' | head -3)

    echo -e "${GREEN}${TOP_LEFT}${HLINE}┬─${WHITE} NETWORK INFORMATION ${NC}${GREEN}────────────────────────────────────${TOP_RIGHT}"

    for iface in $interfaces; do
        local ip_addr=$(ip -4 addr show $iface 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
        if [ -n "$ip_addr" ]; then
            local rx_bytes=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0)
            local tx_bytes=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0)
            local rx_mb=$(awk "BEGIN {printf \"%.1f\", $rx_bytes/1024/1024}")
            local tx_mb=$(awk "BEGIN {printf \"%.1f\", $tx_bytes/1024/1024}")

            echo -e "${GREEN}${VLINE}${NC}  ${WHITE}${iface}${NC}"
            echo -e "${GREEN}${VLINE}${NC}    IP: ${ip_addr}"
            echo -e "${GREEN}${VLINE}${NC}    RX: ${rx_mb}MB  |  TX: ${tx_mb}MB"
        fi
    done

    local connections=$(netstat -an 2>/dev/null | grep ESTABLISHED | wc -l)
    echo -e "${GREEN}${VLINE}${NC}  ${WHITE}Connections:${NC} ${connections}"
    echo -e "${GREEN}${BOTTOM_LEFT}${HLINE}┴────────────────────────────────────────────────────────────${BOTTOM_RIGHT}"
}

# Get Top Processes
get_top_processes() {
    echo -e "${RED}${TOP_LEFT}${HLINE}┬─${WHITE} TOP PROCESSES (CPU) ${NC}${RED}─────────────────────────────────────${TOP_RIGHT}"
    echo -e "${RED}${VLINE}${NC}  ${WHITE}PID${NC}        ${WHITE}USER${NC}       ${WHITE}CPU%${NC}   ${WHITE}MEM%${NC}   ${WHITE}COMMAND${NC}"

    ps aux --sort=-%cpu 2>/dev/null | head -6 | tail -5 | while read line; do
        local user=$(echo "$line" | awk '{print $1}' | cut -c1-10)
        local pid=$(echo "$line" | awk '{print $2}')
        local cpu=$(echo "$line" | awk '{print $3}')
        local mem=$(echo "$line" | awk '{print $4}')
        local cmd=$(echo "$line" | awk '{print $11}' | xargs | cut -c1-20)

        printf "${RED}${VLINE}${NC}  %-8s %-10s %-6s %-6s %-20s\n" "$pid" "$user" "$cpu" "$mem" "$cmd"
    done

    echo -e "${RED}${BOTTOM_LEFT}${HLINE}┴────────────────────────────────────────────────────────────${BOTTOM_RIGHT}"
}

# Print header
print_header() {
    local width=70
    local title=" SYSTEM MONITORING "
    local padding=$((width - ${#title} - 20))

    echo -e "\033[1;36m┌────────────────────────────────────────────────────────────────────┐\033[0m"
    echo -e "\033[1;36m│\033[1;37m${title}\033[0m\033[1;36m$(printf '%*s' $padding '')\033[1;36m│\033[0m"
    echo -e "\033[1;36m│\033[0m  \033[1;32m⬤\033[0m Hostname: \033[1;36m$(hostname)\033[0m"
    echo -e "\033[1;36m│\033[0m  \033[1;32m⬤\033[0m Time:      \033[1;36m$(date '+%Y-%m-%d %H:%M:%S')\033[0m"
    echo -e "\033[1;36m│\033[0m  \033[1;32m⬤\033[0m Uptime:    \033[1;36m$(uptime -p 2>/dev/null | sed 's/up //')\033[0m"
    echo -e "\033[1;36m└────────────────────────────────────────────────────────────────────┘\033[0m"
    echo ""
}

# Main function - render dashboard
render_dashboard() {
    clear
    print_header
    get_cpu_info
    echo ""
    get_memory_info
    echo ""
    get_disk_info
    echo ""
    get_network_info
    echo ""
    get_top_processes
    echo ""
    echo -e "\033[1;90m Press Ctrl+C to exit | Auto-refresh: 2s \033[0m"
}

# Save cursor position
save_cursor() {
    printf "\033[s"
}

# Restore cursor position
restore_cursor() {
    printf "\033[u"
}

# Initial setup
trap 'printf "\033[?25h"; echo -e "\n${GREEN}Exiting ViewMon...${NC}"; exit 0' SIGINT SIGTERM
printf "\033[?25l"

get_terminal_size

# Main loop with smooth refresh
REFRESH=2
FRAME=0

while true; do
    if [ $FRAME -eq 0 ]; then
        render_dashboard
    else
        save_cursor
        printf "\033[1;1H"
        print_header
        save_cursor
        printf "\033[7;1H"
        get_cpu_info
        restore_cursor
        sleep 0.5
    fi

    sleep $REFRESH
    FRAME=$((FRAME + 1))
done
