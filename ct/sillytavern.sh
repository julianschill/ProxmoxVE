#!/usr/bin/env bash
# Copyright (c) 2021-2026 community-scripts ORG
# Author: Julian Schill
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://sillytavern.app/

source <(curl -fsSL https://raw.githubusercontent.com/julianschill/ProxmoxVE/refs/heads/feature/sillytavern/misc/build.func)

APP="SillyTavern"
var_tags="ai;interface;roleplay"
var_cpu="2"
var_ram="2048"
var_disk="4"
var_os="debian"
var_version="13"
var_unprivileged="1"

variables
color
catch_errors

function update_script() {
  check_container_storage
  check_container_resources
  if [[ ! -d /opt/sillytavern ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  RELEASE=$(curl -s https://api.github.com/repos/SillyTavern/SillyTavern/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3)}')
  msg_info "Updating SillyTavern to v${RELEASE}"
  systemctl stop sillytavern
  fetch_and_deploy_gh_release "SillyTavern" "SillyTavern/SillyTavern" "tarball" "/opt/sillytavern"
  cd /opt/sillytavern

  msg_info "Configuring Network Access"
  $STD sed -i '/^whitelist:/,/^[a-z]/ s|  - 127.0.0.1|  - 127.0.0.1\n  - 192.168.0.0/16\n  - 10.0.0.0/8\n  - 172.16.0.0/12\n  - fe80::/10|' /opt/sillytavern/config.yaml
  msg_ok "Network Access Configured"

  msg_info "Updating Dependencies"
  export NODE_ENV=production
  $STD npm install --no-save --no-audit --no-fund --omit=dev
  echo "${RELEASE}" > /opt/
  
  
  SillyTavern_version.txt
  systemctl start sillytavern
  msg_ok "Updated Successfully to v${RELEASE}"
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8000${CL}"
