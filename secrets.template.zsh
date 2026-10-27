# ── Database connections for Neovim (dadbod-ui) ────────────────────────────
# Uncomment a line, replace USER / PASSWORD / HOST / DBNAME, then run: exec zsh
# Format:  sqlserver://USER:PASSWORD@HOST:PORT/DATABASE?trustServerCertificate=true
# URL-encode special characters in the password:
#   \ = %5C   @ = %40   # = %23   : = %3A   / = %2F   % = %25   ? = %3F
# A connection whose variable is unset or empty is simply not shown in the UI.

# 1) SQL Server running in Podman on this machine
# export DB_PODMAN_URL="sqlserver://sa:PASSWORD@localhost:1433/master?trustServerCertificate=true"

# 2) Office server on the local network
# export DB_LAN_URL="sqlserver://USER:PASSWORD@192.168.29.251:1433/DBNAME?trustServerCertificate=true"

# 3) DigitalOcean server (goes over the internet; prefer an SSH tunnel)
# export DB_DO_URL="sqlserver://USER:PASSWORD@DO_HOST:1433/DBNAME?encrypt=true"
