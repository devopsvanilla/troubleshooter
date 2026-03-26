#!/usr/bin/env bash

run_capture_command() {
  local index="$1"
  local category="$2"
  local identifier="$3"
  local description="$4"
  local privileged="$5"
  local timeout_seconds="$6"
  local command_string="$7"

  local slug output_file stdout_file stderr_file final_command status exit_code start_epoch end_epoch duration dependency
  slug="$(slugify "${identifier}")"
  output_file="$(command_output_path "${index}" "${slug}")"
  stdout_file="${output_file}.stdout.tmp"
  stderr_file="${output_file}.stderr.tmp"
  dependency="${command_string%% *}"
  status="ok"
  exit_code=0
  # Se o usuário pediu para forçar sudo, tente sudo em todos os comandos possíveis
  if [[ "${TROUBLESHOOTER_FORCE_SUDO:-0}" == "1" ]]; then
    if has_sudo_non_interactive; then
      final_command="sudo -n ${command_string}"
    else
      final_command="${command_string}"
    fi
  else
    if [[ "${privileged}" == "yes" ]]; then
      if has_sudo_non_interactive; then
        final_command="sudo -n ${command_string}"
      else
        status="needs_sudo"
        exit_code=126
        cat >"${output_file}" <<EOF
# ${identifier}
# status: ${status}
# category: ${category}
# description: ${description}
# command: ${command_string}
# captured_at: $(iso_timestamp)

This command requires elevated privileges and sudo was not available in non-interactive mode.
EOF
        append_summary_line "- [${status}] ${identifier} — ${description}"
        append_manifest_entry "{\"index\":${index},\"id\":\"$(json_escape \"${identifier}\")\",\"category\":\"$(json_escape \"${category}\")\",\"description\":\"$(json_escape \"${description}\")\",\"command\":\"$(json_escape \"${command_string}\")\",\"status\":\"${status}\",\"exitCode\":${exit_code},\"timeoutSeconds\":${timeout_seconds},\"outputFile\":\"$(json_escape \"${output_file}\")\",\"startedAt\":\"$(iso_timestamp)\",\"finishedAt\":\"$(iso_timestamp)\",\"durationSeconds\":0,\"privileged\":true}"
        return 0
      fi
    else
      final_command="${command_string}"
    fi
  fi
  start_epoch="$(date +%s)"

  if ! command_exists "${dependency}"; then
    status="missing_dependency"
    exit_code=127
    cat >"${output_file}" <<EOF
# ${identifier}
# status: ${status}
# category: ${category}
# description: ${description}
# command: ${command_string}
# captured_at: $(iso_timestamp)

The required command was not found in PATH: ${dependency}
EOF
    append_summary_line "- [${status}] ${identifier} — missing command: ${dependency}"
    append_manifest_entry "{\"index\":${index},\"id\":\"$(json_escape "${identifier}")\",\"category\":\"$(json_escape "${category}")\",\"description\":\"$(json_escape "${description}")\",\"command\":\"$(json_escape "${command_string}")\",\"status\":\"${status}\",\"exitCode\":${exit_code},\"timeoutSeconds\":${timeout_seconds},\"outputFile\":\"$(json_escape "${output_file}")\",\"startedAt\":\"$(iso_timestamp)\",\"finishedAt\":\"$(iso_timestamp)\",\"durationSeconds\":0,\"privileged\":false}"
    return 0
  fi

  if command_exists timeout; then
    if timeout "${timeout_seconds}" bash -lc "${final_command}" >"${stdout_file}" 2>"${stderr_file}"; then
      exit_code=0
    else
      exit_code=$?
    fi
  else
    if bash -lc "${final_command}" >"${stdout_file}" 2>"${stderr_file}"; then
      exit_code=0
    else
      exit_code=$?
    fi
  fi

  if [[ ${exit_code} -eq 124 ]]; then
    status="timeout"
  elif [[ ${exit_code} -ne 0 ]]; then
    status="failed"
  fi

  end_epoch="$(date +%s)"
  duration=$((end_epoch - start_epoch))

  {
    printf '# %s\n' "${identifier}"
    printf '# status: %s\n' "${status}"
    printf '# category: %s\n' "${category}"
    printf '# description: %s\n' "${description}"
    printf '# command: %s\n' "${command_string}"
    printf '# privileged: %s\n' "${privileged}"
    printf '# timeout_seconds: %s\n' "${timeout_seconds}"
    printf '# exit_code: %s\n' "${exit_code}"
    printf '# duration_seconds: %s\n' "${duration}"
    printf '# captured_at: %s\n\n' "$(iso_timestamp)"
    printf '## STDOUT\n'
    cat "${stdout_file}" 2>/dev/null || true
    printf '\n\n## STDERR\n'
    cat "${stderr_file}" 2>/dev/null || true
  } >"${output_file}"

  rm -f "${stdout_file}" "${stderr_file}"

  append_summary_line "- [${status}] ${identifier} — ${description}"
  append_manifest_entry "{\"index\":${index},\"id\":\"$(json_escape "${identifier}")\",\"category\":\"$(json_escape "${category}")\",\"description\":\"$(json_escape "${description}")\",\"command\":\"$(json_escape "${command_string}")\",\"status\":\"${status}\",\"exitCode\":${exit_code},\"timeoutSeconds\":${timeout_seconds},\"outputFile\":\"$(json_escape "${output_file}")\",\"startedAt\":\"$(iso_timestamp)\",\"finishedAt\":\"$(iso_timestamp)\",\"durationSeconds\":${duration},\"privileged\":$([[ "${privileged}" == "yes" ]] && printf true || printf false)}"
}
