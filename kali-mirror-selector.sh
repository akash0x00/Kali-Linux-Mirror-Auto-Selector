#!/usr/bin/env bash
set -euo pipefail

# Color definitions for terminal output
RED='\033[31m'
LIGHT_RED='\033[91m'
GREEN='\033[32m'
YELLOW='\033[93m'
BLUE='\033[94m'
SKY_BLUE='\033[1;38;5;39m'
NC='\033[0m'

# Kali release and components
RELEASE="kali-rolling"
COMPONENTS="main contrib non-free non-free-firmware"

# List of reliable Kali mirrors (geographically diverse)
MIRRORS=(
  "https://ftp2.nluug.nl/os/Linux/distr/kali"
  "https://ftp1.nluug.nl/os/Linux/distr/kali"
  "https://mirror.neostrada.nl/kali"
  "https://mirror.ox.ac.uk/sites/archive.kali.org/kali"
  "https://mirror.sg.gs/kali"
  "https://ftp.halifax.rwth-aachen.de/kali"
  "https://mirrors.ocf.berkeley.edu/kali"
  "https://ftp.jaist.ac.jp/pub/Linux/kali"
  "https://ftp.acc.umu.se/mirror/kali.org/kali"
  "https://mirrors.ircam.fr/pub/kali"
  "http://http.kali.org/kali"
)

echo -e "\n${SKY_BLUE}Kali Linux Mirror Auto-Selector${NC}"
echo "_________________________________________________________________________________"
echo -e "\n${BLUE}[*]${NC} Testing mirrors (reachability + latency)"

BEST_MIRROR=""
BEST_TIME=999999

for mirror in "${MIRRORS[@]}"; do
  printf "${BLUE}[*]${NC} %-60s " "$mirror"
  # Test mirror with curl (5s connect timeout, 10s max, 15s hard timeout wrapper)
  TIME=$(timeout 15s bash -c "curl -o /dev/null -s --connect-timeout 5 --max-time 10 -w '%{time_total}' '$mirror/dists/$RELEASE/Release' 2>/dev/null || echo ''" || echo "")
  if [[ -z "$TIME" ]] || [[ "$TIME" == "0.000" ]]; then
    echo -e "${RED}[FAIL]${NC}"
  else
    printf "${GREEN}[OK]${NC} %.3fs\n" "$TIME"
    # Update best mirror if this one is faster
    awk "BEGIN {exit !($TIME < $BEST_TIME)}" && { BEST_TIME="$TIME"; BEST_MIRROR="$mirror"; }
  fi
done

# Exit if no working mirrors found
[[ -z "$BEST_MIRROR" ]] && { echo -e "\n${RED}[ERROR]${NC} No reachable Kali mirrors found."; exit 1; }

echo -e "\n${GREEN}[+]${NC} Fastest reachable mirror:"
echo -e "    ${YELLOW}$BEST_MIRROR${NC}"
printf "    Latency: ${GREEN}%.3fs${NC}\n\n" "$BEST_TIME"

# Ask user confirmation before applying changes
echo -e "${LIGHT_RED}[?]${NC} Apply this mirror and update APT? [Y/n] \c"
read -r reply
[[ "$reply" =~ ^[nN] ]] && { echo -e "${YELLOW}[ABORT]${NC} No changes were made."; exit 0; }

# Create timestamped backup
BACKUP="/etc/apt/sources.list.bak.$(date +%F_%H-%M-%S)"

echo -e "\n${BLUE}[*]${NC} Backing up /etc/apt/sources.list → $BACKUP"
sudo cp /etc/apt/sources.list "$BACKUP"

echo -e "${BLUE}[*]${NC} Writing new sources.list"
echo "deb $BEST_MIRROR $RELEASE $COMPONENTS" | sudo tee /etc/apt/sources.list >/dev/null

echo -e "${BLUE}[*]${NC} Cleaning APT cache"
sudo apt clean

echo -e "${BLUE}[*]${NC} Updating package lists"
printf "_________________________________________________________________________________\n"
sudo apt update

echo -e "\n${GREEN}[DONE]${NC} Kali mirror updated successfully.\n"
