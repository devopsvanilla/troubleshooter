#!/usr/bin/env bash

COLOR_RESET='\033[0m'
COLOR_INFO='\033[1;34m'   # Azul forte
COLOR_WARN='\033[1;33m'   # Amarelo
COLOR_ERROR='\033[1;31m'  # Vermelho
COLOR_PROMPT='\033[1;35m' # Magenta

log_info() {
  printf "${COLOR_INFO}[INFO] %s${COLOR_RESET}\n" "$*" >&2
}

log_warn() {
  printf "${COLOR_WARN}[WARN] %s${COLOR_RESET}\n" "$*" >&2
}

log_error() {
  printf "${COLOR_ERROR}[ERROR] %s${COLOR_RESET}\n" "$*" >&2
}

die() {
  log_error "$*"
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

slugify() {
  local input="$1"
  input="$(printf '%s' "${input}" | tr '[:upper:]' '[:lower:]')"
  input="$(printf '%s' "${input}" | sed -E 's/[^a-z0-9]+/_/g; s/^_+//; s/_+$//')"
  printf '%s' "${input:-item}"
}

json_escape() {
  local value="$1"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

iso_timestamp() {
  date '+%Y-%m-%dT%H:%M:%S%z'
}

session_timestamp() {
  date '+%Y%m%d-%H%M%S'
}

best_effort_hostname() {
  hostname 2>/dev/null || uname -n 2>/dev/null || printf 'unknown-host'
}

has_sudo_non_interactive() {
  command_exists sudo && sudo -n true >/dev/null 2>&1
}

is_interactive_shell() {
  [[ -t 0 && -t 1 ]]
}
