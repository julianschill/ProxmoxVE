#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/julianschill/ProxmoxVE/refs/heads/dev/stashapp/misc/build.func)
# Copyright (c) 2021-2026 community-scripts ORG
# Author: Gemini AI
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/stashapp/stash

# Setting variables for build.func
APP="Stash"
var_tags="${var_tags:-media}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-8}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -f /opt/stash/stash ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  msg_info "Updating ${APP}"
  systemctl stop stash
  RELEASE=$(curl -s https://api.github.com/repos/stashapp/stash/releases/latest | grep "tag_name" | awk -F '"' '{print $4}')
  wget -q -O /opt/stash/stash "https://github.com/stashapp/stash/releases/download/${RELEASE}/stash-linux-amd64"
  chmod +x /opt/stash/stash
  systemctl start stash
  msg_ok "Updated ${APP} to ${RELEASE}"
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:9999${CL}"
