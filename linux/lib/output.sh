#!/usr/bin/env bash

SESSION_DIR=""
SESSION_COMMAND_DIR=""
MANIFEST_ENTRIES_FILE=""
SUMMARY_FILE=""
MANIFEST_FILE=""

init_session_output() {
  local timestamp profile output_dir
  timestamp="$(session_timestamp)"
  profile="$1"
  output_dir="${2:-}"
  if [[ -z "${output_dir}" ]]; then
    output_dir="$(pwd)"
  fi
  SESSION_DIR="${output_dir}/start-session/state/${timestamp}"
  SESSION_COMMAND_DIR="${SESSION_DIR}/commands"
  MANIFEST_ENTRIES_FILE="${SESSION_DIR}/.manifest.entries.jsonl"
  SUMMARY_FILE="${SESSION_DIR}/summary.md"
  MANIFEST_FILE="${SESSION_DIR}/manifest.json"

  mkdir -p "${SESSION_COMMAND_DIR}"
  : >"${MANIFEST_ENTRIES_FILE}"

  cat >"${SUMMARY_FILE}" <<EOF
# Start session summary

- Timestamp: ${timestamp}
- Captured at: $(iso_timestamp)
- Host: $(best_effort_hostname)
- User: ${USER:-unknown}
- Profile: ${profile}
- Working directory: $(pwd)

## Command results

EOF
}

append_summary_line() {
  printf '%s\n' "$1" >>"${SUMMARY_FILE}"
}

command_output_path() {
  local index="$1"
  local slug="$2"
  printf '%s/%03d_%s.log' "${SESSION_COMMAND_DIR}" "${index}" "${slug}"
}

append_manifest_entry() {
  local entry="$1"
  printf '%s\n' "${entry}" >>"${MANIFEST_ENTRIES_FILE}"
}

finalize_manifest() {
  local profile="$1"
  local joined_entries cwd_value
  cwd_value="$(json_escape "$(pwd)")"

  if [[ -s "${MANIFEST_ENTRIES_FILE}" ]]; then
    joined_entries="$(paste -sd, "${MANIFEST_ENTRIES_FILE}")"
  else
    joined_entries=""
  fi

  cat >"${MANIFEST_FILE}" <<EOF
{
  "tool": "linux-troubleshooter",
  "captureType": "start-session",
  "capturedAt": "$(iso_timestamp)",
  "host": "$(json_escape "$(best_effort_hostname)")",
  "user": "$(json_escape "${USER:-unknown}")",
  "profile": "$(json_escape "${profile}")",
  "cwd": "${cwd_value}",
  "sessionDir": "$(json_escape "${SESSION_DIR}")",
  "commands": [${joined_entries}]
}
EOF
}
