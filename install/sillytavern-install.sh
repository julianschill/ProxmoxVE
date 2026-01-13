#!/usr/bin/env bash
# Copyright (c) 2021-2026 community-scripts ORG
# Author: DeinName
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://sillytavern.app/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl sudo mc gpg build-essential python3 tar
msg_ok "Installed Dependencies"

msg_info "Installing Node.js"
NODE_VERSION="22" setup_nodejs
msg_ok "Installed Node.js"

msg_info "Installing SillyTavern"
mkdir -p /var/lib/sillytavern-data
RELEASE=$(curl -s https://api.github.com/repos/SillyTavern/SillyTavern/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3)}')
fetch_and_deploy_gh_release "SillyTavern" "SillyTavern/SillyTavern" "source" "latest" "/opt/sillytavern"
cd /opt/sillytavern
export NODE_ENV=production
$STD npm install --no-save --no-audit --no-fund --omit=dev
echo "${RELEASE}" > /opt/sillytavern_version.txt
msg_ok "Installed SillyTavern v${RELEASE}"

msg_info "Configuring Network Access"
$STD sed -i '/^whitelist:/,/^[a-z]/ s|  - 127.0.0.1|  - 127.0.0.1\n  - 192.168.0.0/16\n  - 10.0.0.0/8\n  - 172.16.0.0/12\n  - fe80::/10|' /opt/sillytavern/config.yaml
msg_ok "Network Access Configured"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/sillytavern.service
[Unit]
Description=SillyTavern Service
After=network.target

[Service]
WorkingDirectory=/opt/sillytavern
Environment=NODE_ENV=production
ExecStart=/usr/bin/node server.js --dataRoot="/var/lib/sillytavern-data" --listen=true
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now sillytavern
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
