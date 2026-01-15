#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/stashapp/stash

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os
setup_hwaccel

msg_info "Installing Dependencies"
$STD apt install -y \
  ffmpeg \
  ca-certificates \
  curl \
  libvips-dev
msg_ok "Installed Dependencies"

msg_info "Downloading Stash"
mkdir -p /opt/stash
mkdir -p /var/lib/stash/{config,data,blobs}
RELEASE=$(curl -s https://api.github.com/repos/stashapp/stash/releases/latest | grep "tag_name" | awk -F '"' '{print $4}')
wget -q -O /opt/stash/stash "https://github.com/stashapp/stash/releases/download/${RELEASE}/stash-linux"
chmod +x /opt/stash/stash
msg_ok "Downloaded Stash"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/stash.service
[Unit]
Description=Stash Media Organizer
After=network.target

[Service]
Type=simple
WorkingDirectory=/var/lib/stash
ExecStart=/opt/stash/stash -c /var/lib/stash/config/config.yml
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now stash
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
