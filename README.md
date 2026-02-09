# Kali-Linux-Mirror-Auto-Selector
A smart, automated tool to find and configure the fastest reachable Kali Linux mirror for your network environment.
Especially useful in corporate/restricted networks where the default Kali redirector (http://http.kali.org) is often blocked.


### Problem Statement
The default Kali mirror redirector frequently fails in:
- Corporate networks with strict firewall policies
- VPN connections with limited mirror access
- Geographic regions with poor connectivity to default mirrors
- Isolated environments where specific mirrors are blocked

This leads to complete package management failure - `apt update`, `apt install`, and `apt upgrade` all become unreliable or impossible, effectively breaking the entire Kali package ecosystem.


### Solution
This script automatically:
- Tests multiple Kali mirrors for reachability
- Measures actual latency to find the fastest one
- Safely updates /etc/apt/sources.list with the best mirror
- Creates timestamped backups before any changes
- Requires explicit user confirmation before applying changes

### Installation and Use
```bash
# Download the script
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/kali-mirror-selector/main/kali-mirror-selector.sh

# Make it executable
chmod +x kali-mirror-selector.sh

# Run it
./kali-mirror-selector.sh
```

<img width="1263" height="1113" alt="Screenshot 2026-02-09 110158" src="https://github.com/user-attachments/assets/cffacd34-371d-4da5-b6ad-59a361aa2d1b" />

### License
MIT License - feel free to use, modify, and distribute.

### Acknowledgments
- Kali Linux team for maintaining the distribution
- Mirror maintainers for providing reliable infrastructure

---

Note: This tool modifies system files. Always review the code before running scripts with sudo privileges.
