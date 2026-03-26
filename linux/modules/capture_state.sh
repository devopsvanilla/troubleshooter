#!/usr/bin/env bash

CAPTURE_IDS=()
CAPTURE_CATEGORIES=()
CAPTURE_PRIVILEGED=()
CAPTURE_TIMEOUTS=()
CAPTURE_DESCRIPTIONS=()
CAPTURE_COMMANDS=()

capture_reset_catalog() {
  CAPTURE_IDS=()
  CAPTURE_CATEGORIES=()
  CAPTURE_PRIVILEGED=()
  CAPTURE_TIMEOUTS=()
  CAPTURE_DESCRIPTIONS=()
  CAPTURE_COMMANDS=()
}

capture_add() {
  CAPTURE_IDS+=("$1")
  CAPTURE_CATEGORIES+=("$2")
  CAPTURE_PRIVILEGED+=("$3")
  CAPTURE_TIMEOUTS+=("$4")
  CAPTURE_DESCRIPTIONS+=("$5")
  CAPTURE_COMMANDS+=("$6")
}

capture_build_quick() {
  capture_add "date" "context" "no" 10 "Current server date/time" "date"
  capture_add "uname_a" "context" "no" 10 "Kernel and architecture" "uname -a"
  capture_add "os_release" "context" "no" 10 "Distribution identification" "cat /etc/os-release"
  capture_add "hostnamectl" "context" "no" 10 "Host metadata" "hostnamectl"
  capture_add "uptime" "context" "no" 10 "Load and uptime" "uptime"
  capture_add "who" "context" "no" 10 "Logged-in users" "who"
  capture_add "last_x_head" "context" "no" 15 "Recent boots and runlevel changes" "last -x | head -n 50"
  capture_add "journal_boot_warning" "boot_kernel" "no" 20 "Warnings from current boot" "journalctl -xb -p warning --no-pager"
  capture_add "dmesg_tail" "boot_kernel" "no" 20 "Recent kernel ring buffer lines" "dmesg -T | tail -n 120"
  capture_add "systemctl_failed" "services" "no" 15 "Failed systemd units" "systemctl list-units --failed --no-pager"
  capture_add "systemctl_running_services" "services" "no" 20 "Running systemd services" "systemctl list-units --type=service --state=running --no-pager"
  capture_add "free_h" "cpu_memory" "no" 10 "Memory overview" "free -h"
  capture_add "vmstat" "cpu_memory" "no" 15 "VM statistics sample" "vmstat 1 3"
  capture_add "top_batch" "cpu_memory" "no" 20 "Top processes snapshot" "top -b -n 1"
  capture_add "df_ht" "disk" "no" 15 "Filesystem capacity and types" "df -hT"
  capture_add "lsblk_f" "disk" "no" 15 "Block devices and filesystems" "lsblk -f"
  capture_add "findmnt" "disk" "no" 15 "Mounted filesystems view" "findmnt"
  capture_add "ss_tulpn" "network" "no" 20 "Listening sockets and processes" "ss -tulpn"
  capture_add "ip_br_a" "network" "no" 10 "Compact interface addresses" "ip -br a"
  capture_add "ip_route" "network" "no" 10 "Routing table" "ip route"
  capture_add "resolvectl_status" "network" "no" 15 "Resolver state when systemd-resolved exists" "resolvectl status"
  capture_add "ps_auxwwf" "processes" "no" 20 "Full process tree style snapshot" "ps auxwwf"
  capture_add "lsof_nP" "files_locks" "no" 30 "Open files and sockets" "lsof -nP"
}

capture_build_standard() {
  capture_build_quick
  capture_add "timedatectl" "context" "no" 10 "Time sync and timezone" "timedatectl"
  capture_add "systemctl_timers" "services" "no" 20 "Active and inactive timers" "systemctl list-timers --all --no-pager"
  capture_add "systemctl_service_files" "services" "no" 20 "Installed systemd service unit files" "systemctl list-unit-files --type=service --no-pager"
  capture_add "journal_disk_usage" "services" "no" 10 "Journal disk consumption" "journalctl --disk-usage"
  capture_add "service_status_all" "services" "no" 20 "Service status list for SysV/upstart compatible hosts" "service --status-all"
  capture_add "chkconfig_list" "services" "no" 20 "Configured services for chkconfig-based systems" "chkconfig --list"
  capture_add "initctl_list" "services" "no" 15 "Upstart job state list" "initctl list"
  capture_add "openrc_rc_status" "services" "no" 20 "OpenRC service status overview" "rc-status -a"
  capture_add "runit_sv_status" "services" "no" 20 "runit service status overview" "sv status /etc/service/*"
  capture_add "s6_rc_list" "services" "no" 15 "s6-rc managed service list" "s6-rc -a list"
  capture_add "mpstat_all" "cpu_memory" "no" 20 "CPU usage by core" "mpstat -P ALL 1 3"
  capture_add "pidstat" "cpu_memory" "no" 20 "Per-process CPU and memory sample" "pidstat 1 3"
  capture_add "pressure_cpu" "cpu_memory" "no" 10 "CPU pressure stall information" "cat /proc/pressure/cpu"
  capture_add "pressure_memory" "cpu_memory" "no" 10 "Memory pressure stall information" "cat /proc/pressure/memory"
  capture_add "pressure_io" "cpu_memory" "no" 10 "I/O pressure stall information" "cat /proc/pressure/io"
  capture_add "proc_meminfo" "cpu_memory" "no" 10 "Detailed memory statistics from kernel" "cat /proc/meminfo"
  capture_add "du_root_top" "disk" "no" 60 "Top-level disk usage under root filesystem" "du -xhd1 / 2>/dev/null | sort -h"
  capture_add "iostat_xz" "disk" "no" 20 "Extended disk I/O statistics" "iostat -xz 1 3"
  capture_add "ss_summary" "network" "no" 10 "Socket summary" "ss -s"
  capture_add "ip_rule" "network" "no" 10 "Policy routing rules" "ip rule"
  capture_add "ip_neigh" "network" "no" 10 "ARP/neighbor table" "ip neigh"
  capture_add "nft_ruleset" "network" "yes" 20 "nftables ruleset" "nft list ruleset"
  capture_add "iptables_save" "network" "yes" 20 "iptables configuration" "iptables-save"
  capture_add "resolv_conf" "network" "no" 10 "DNS resolver configuration file" "cat /etc/resolv.conf"
  capture_add "etc_hosts" "network" "no" 5 "Hosts file" "cat /etc/hosts"
  capture_add "etc_nsswitch" "network" "no" 5 "Name service switch config" "cat /etc/nsswitch.conf 2>/dev/null || true"
  capture_add "etc_network_interfaces" "network" "no" 5 "Debian network interfaces" "cat /etc/network/interfaces 2>/dev/null || true"
  capture_add "etc_netplan" "network" "no" 5 "Netplan configs (Ubuntu)" "cat /etc/netplan/*.yaml 2>/dev/null || true"
  capture_add "etc_sysconfig_network" "network" "no" 5 "RHEL/CentOS network-scripts" "cat /etc/sysconfig/network-scripts/ifcfg-* 2>/dev/null || true"
  capture_add "etc_networkmanager" "network" "no" 5 "NetworkManager main config" "cat /etc/NetworkManager/NetworkManager.conf 2>/dev/null || true"
  capture_add "etc_networkmanager_profiles" "network" "no" 5 "NetworkManager connection profiles" "cat /etc/NetworkManager/system-connections/* 2>/dev/null || true"
  capture_add "etc_firewalld" "network" "no" 5 "firewalld main config" "cat /etc/firewalld/firewalld.conf 2>/dev/null || true"
  capture_add "firewalld_list" "network" "yes" 10 "firewalld runtime and permanent config" "firewall-cmd --list-all --permanent 2>/dev/null || true; firewall-cmd --list-all 2>/dev/null || true"
  capture_add "ufw_status" "network" "yes" 10 "ufw status (Ubuntu firewall)" "ufw status verbose 2>/dev/null || true"
  capture_add "nmcli_general" "network" "no" 10 "NetworkManager general status" "nmcli general status 2>/dev/null || true"
  capture_add "nmcli_dev" "network" "no" 10 "NetworkManager device status" "nmcli device status 2>/dev/null || true"
  capture_add "ifconfig_a" "network" "no" 10 "ifconfig output (legacy)" "ifconfig -a 2>/dev/null || true"
  capture_add "route_n" "network" "no" 10 "route -n output (legacy)" "route -n 2>/dev/null || true"
  capture_add "dig_etc_hosts" "network" "no" 10 "dig hosts and resolvers" "dig +short -x 127.0.0.1 2>/dev/null || true; dig +short google.com 2>/dev/null || true"
  capture_add "nslookup_google" "network" "no" 10 "nslookup test (google.com)" "nslookup google.com 2>/dev/null || true"
  capture_add "pstree_alp" "processes" "no" 15 "Process ancestry tree" "pstree -alp"
  capture_add "proc_file_nr" "files_locks" "no" 10 "Kernel file handle counters" "cat /proc/sys/fs/file-nr"
  capture_add "journal_recent_warning" "logs" "no" 25 "Warnings in the last hour" "journalctl -p warning --since '1 hour ago' --no-pager"
  capture_add "journal_recent_tail" "logs" "no" 20 "Recent journal lines" "journalctl -n 300 --no-pager"
  capture_add "tail_syslog" "logs" "no" 10 "Tail syslog when present" "tail -n 200 /var/log/syslog"
  capture_add "tail_messages" "logs" "no" 10 "Tail messages when present" "tail -n 200 /var/log/messages"
  capture_add "tail_authlog" "logs" "no" 10 "Tail auth log when present" "tail -n 200 /var/log/auth.log"
  capture_add "cron_dirs" "automation" "no" 10 "Cron directories and scheduled files" "ls -la /etc/cron.*"
  capture_add "etc_crontab" "automation" "no" 10 "System crontab file" "cat /etc/crontab"
  capture_add "etc_anacrontab" "automation" "no" 10 "Anacron schedule file when present" "cat /etc/anacrontab 2>/dev/null || true"
  capture_add "cron_spool_list" "automation" "no" 10 "Cron spool directories when present" "ls -la /var/spool/cron /var/spool/cron/crontabs 2>/dev/null || true"
  capture_add "crontab_l" "automation" "no" 10 "Current user crontab" "crontab -l"
  capture_add "crontab_root" "automation" "yes" 15 "Root user crontab" "crontab -u root -l 2>/dev/null || true"
  capture_add "crontab_all_users" "automation" "yes" 40 "Crontab for all local users" "bash -lc 'for user in \$(getent passwd | cut -d: -f1); do echo \"### \${user} ###\"; crontab -u \"\${user}\" -l 2>&1 || true; echo; done'"
  capture_add "atq_jobs" "automation" "no" 10 "Queued at/batch jobs" "atq"
  capture_add "at_allow_deny" "automation" "no" 10 "at allow/deny configuration" "cat /etc/at.allow /etc/at.deny 2>/dev/null || true"
  capture_add "periodic_dirs" "automation" "no" 10 "Periodic job directories (Alpine/BusyBox style)" "ls -la /etc/periodic/* 2>/dev/null || true"
  capture_add "docker_ps" "containers" "no" 15 "Docker containers when docker exists" "docker ps -a"
  capture_add "podman_ps" "containers" "no" 15 "Podman containers when podman exists" "podman ps -a"
}

capture_build_deep() {
  capture_build_standard
  # (Se houver comandos de rede exclusivos para deep, adicionar aqui futuramente)
  capture_add "lsmod" "boot_kernel" "no" 15 "Loaded kernel modules" "lsmod"
  capture_add "systemd_analyze_blame" "boot_kernel" "no" 20 "Slow systemd units" "systemd-analyze blame"
  capture_add "systemd_critical_chain" "boot_kernel" "no" 20 "Critical boot dependency chain" "systemd-analyze critical-chain"
  capture_add "blkid" "disk" "yes" 15 "Filesystem identifiers" "blkid"
  capture_add "smartctl_health_sda" "disk" "yes" 30 "SMART health for /dev/sda" "smartctl -H /dev/sda"
  capture_add "ethtool_all" "network" "yes" 30 "Interface features for all discovered NICs" 'for dev in $(ls /sys/class/net); do echo "### $dev ###"; ethtool "$dev"; echo; done'
  capture_add "recent_etc_changes" "security" "no" 30 "Files under /etc changed in the last 7 days" "find /etc -type f -mtime -7 2>/dev/null | sort | head -n 300"
  capture_add "lvm_pvs" "disk" "yes" 15 "LVM physical volumes" "pvs"
  capture_add "lvm_vgs" "disk" "yes" 15 "LVM volume groups" "vgs"
  capture_add "lvm_lvs" "disk" "yes" 15 "LVM logical volumes" "lvs"
  capture_add "dpkg_list" "packages" "no" 30 "Installed packages via dpkg" "dpkg -l 2>/dev/null | sort"
  capture_add "rpm_qa" "packages" "no" 30 "Installed packages via rpm" "rpm -qa 2>/dev/null | sort"
  capture_add "apt_installed" "packages" "no" 30 "Installed packages via apt" "apt list --installed 2>/dev/null"
  capture_add "dnf_list" "packages" "no" 30 "Installed packages via dnf" "dnf list installed 2>/dev/null"
  capture_add "zypper_packages" "packages" "no" 30 "Installed packages via zypper (openSUSE/SLES)" "zypper packages --installed-only 2>/dev/null"
  capture_add "apk_list" "packages" "no" 15 "Installed packages via apk (Alpine)" "apk list --installed 2>/dev/null"
  capture_add "npm_global" "packages" "no" 20 "Globally installed npm packages" "npm list -g --depth=0 2>/dev/null"
  capture_add "pip3_list" "packages" "no" 20 "Installed Python packages via pip3" "pip3 list --format=columns 2>/dev/null"
  capture_add "go_env" "packages" "no" 10 "Go runtime environment and version" "go env"
  capture_add "cargo_list" "packages" "no" 20 "Installed Rust packages via cargo" "cargo install --list 2>/dev/null"
  capture_add "lspci" "hardware" "no" 15 "PCI devices" "lspci"
  capture_add "lsusb" "hardware" "no" 15 "USB devices" "lsusb"
  capture_add "dmidecode" "hardware" "yes" 20 "Hardware and BIOS information (DMI/SMBIOS)" "dmidecode"
  capture_add "listen_port_grep" "security" "no" 30 "Config snippets mentioning Listen or Port" "grep -R -n -E 'Listen|Port' /etc 2>/dev/null | head -n 300"
  capture_add "getent_passwd" "security" "no" 15 "Local and remote passwd entries" "getent passwd"
  capture_add "shell_history_all_users" "security" "yes" 60 "Shell history files for all users (bash/zsh/fish/ash/sh)" "bash -lc 'mask_sensitive=\"\${TROUBLESHOOTER_MASK_SENSITIVE:-0}\"; getent passwd | while IFS=: read -r user _ uid _ _ home shell; do [ -d \"\${home}\" ] || continue; echo \"### \${user} (uid=\${uid}, shell=\${shell}, home=\${home}) ###\"; for hist in \"\${home}/.bash_history\" \"\${home}/.zsh_history\" \"\${home}/.local/share/fish/fish_history\" \"\${home}/.ash_history\" \"\${home}/.sh_history\"; do if [ -r \"\${hist}\" ]; then echo \"--- \${hist} ---\"; if [ \"\${mask_sensitive}\" = \"1\" ]; then tail -n 200 \"\${hist}\" 2>/dev/null | sed -E \"s/((pass(word)?|token|secret|api[_-]?key|authorization|bearer)[[:space:]]*[:=][[:space:]]*)[^[:space:]]+/\\1***MASKED***/Ig; s/(AKIA[0-9A-Z]{16})/***MASKED***/g; s/(ghp_[A-Za-z0-9]{20,})/***MASKED***/g\"; else tail -n 200 \"\${hist}\" 2>/dev/null || true; fi; echo; fi; done; done'"
}

capture_build_catalog() {
  local profile="$1"
  capture_reset_catalog
  case "${profile}" in
    quick)
      capture_build_quick
      ;;
    standard)
      capture_build_standard
      ;;
    deep)
      capture_build_deep
      ;;
    *)
      die "Unknown capture profile: ${profile}"
      ;;
  esac
}

capture_state_main() {
  local profile="${1:-standard}"
  local total_commands index command_count

  capture_build_catalog "${profile}"

  # Forçar flush do histórico de shell para todos os usuários antes de coletar
  log_info "Forçando flush do histórico de shell para todos os usuários (history -a)"
  getent passwd | while IFS=: read -r user _ uid _ _ home shell; do
    # Só tenta para shells interativos conhecidos e diretórios válidos
    if [ -d "$home" ] && [[ "$shell" =~ bash|zsh|ash|sh ]]; then
      if [ "$uid" -ge 1000 ] || [ "$uid" -eq 0 ]; then
        su - "$user" -c 'if [ -n "$BASH_VERSION" ]; then history -a; fi; if [ -n "$ZSH_VERSION" ]; then fc -AI; fi' 2>/dev/null || true
      fi
    fi
  done
  local output_dir="${2:-}"
  if [[ -z "${output_dir}" ]]; then
    output_dir="$(pwd)"
  fi
  init_session_output "${profile}" "${output_dir}"

  append_summary_line "- Session directory: ${SESSION_DIR}"
  append_summary_line "- Command directory: ${SESSION_COMMAND_DIR}"
  append_summary_line ""

  total_commands="${#CAPTURE_IDS[@]}"
  append_summary_line "Planned commands: ${total_commands}"
  append_summary_line ""

  log_info "Starting capture-state (${profile})"
  log_info "Writing artifacts under ${SESSION_DIR}"

  for index in "${!CAPTURE_IDS[@]}"; do
    command_count=$((index + 1))
    log_info "[${command_count}/${total_commands}] ${CAPTURE_IDS[${index}]}"
    run_capture_command \
      "${command_count}" \
      "${CAPTURE_CATEGORIES[${index}]}" \
      "${CAPTURE_IDS[${index}]}" \
      "${CAPTURE_DESCRIPTIONS[${index}]}" \
      "${CAPTURE_PRIVILEGED[${index}]}" \
      "${CAPTURE_TIMEOUTS[${index}]}" \
      "${CAPTURE_COMMANDS[${index}]}"
  done

  finalize_manifest "${profile}"
  rm -f "${MANIFEST_ENTRIES_FILE}"

  log_info "Capture complete"
  log_info "Summary: ${SUMMARY_FILE}"
  log_info "Manifest: ${MANIFEST_FILE}"

  # Compacta o diretório de sessão e remove os arquivos originais
  local session_parent session_name archive_path
  session_parent="$(dirname -- "${SESSION_DIR}")"
  session_name="$(basename -- "${SESSION_DIR}")"
  archive_path="${output_dir}/${session_name}.tar.gz"
  log_info "Compactando sessão em: ${archive_path}"
  tar -czf "${archive_path}" -C "${session_parent}" "${session_name}"
  if [ $? -eq 0 ]; then
    log_info "Removendo diretório original da sessão: ${SESSION_DIR}"
    rm -rf "${SESSION_DIR}"
    log_info "Sessão compactada e diretório removido."
  else
    log_info "Falha ao compactar sessão. Diretório original preservado."
  fi
}
