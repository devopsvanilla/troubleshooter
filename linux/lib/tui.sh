#!/usr/bin/bash
tui_input_dir() {
  local title="$1"
  local message="$2"
  local default_dir="$3"
  local dir=""
  local backend
  backend="$(_tui_backend)"

  case "${backend}" in
    dialog)
      dir=$(dialog --title "${title}" --inputbox "${message}" 12 72 "${default_dir}" 3>&1 1>&2 2>&3)
      ;;
    whiptail)
      dir=$(whiptail --title "${title}" --inputbox "${message}" 12 72 "${default_dir}" 3>&1 1>&2 2>&3)
      ;;
    *)
      printf '\n== %s ==\n%s\n' "$title" "$message"
      read -r -e -p "Diretório [${default_dir}]: " dir
      dir="${dir:-$default_dir}"
      ;;
  esac

  # Expande variáveis e ~
  dir=$(eval echo "$dir")

  # Permite cancelar
  if [[ -z "$dir" ]]; then
    printf ''
    return 1
  fi

  # Cria diretório se não existir
  if [[ ! -d "$dir" ]]; then
    mkdir -p -- "$dir" 2>/dev/null || {
      tui_info "Erro" "Não foi possível criar o diretório: $dir"
      return 1
    }
  fi

  printf '%s' "$dir"
  return 0
}
#!/usr/bin/env bash
# Prompt de input robusto para diretório, com expansão de variáveis, criação e opção de sair
# Uso: tui_input_dir "Título" "Mensagem" "Valor padrão"
# Prompt de input robusto para diretório, com expansão de variáveis, criação e opção de sair
# Uso: tui_input_dir "Título" "Mensagem" "Valor padrão"
# Prompt de input robusto para diretório, com expansão de variáveis, criação e opção de sair
# Uso: tui_input_dir "Título" "Mensagem" "Valor padrão"
# Prompt de input robusto para diretório, com expansão de variáveis, criação e opção de sair
# Uso: tui_input_dir "Título" "Mensagem" "Valor padrão"

: "${TUI_FORCE_PLAIN:=0}"

_tui_backend() {
  if [[ "${TUI_FORCE_PLAIN}" == "1" ]]; then
    printf 'plain'
    return
  fi

  if command -v dialog >/dev/null 2>&1; then
    printf 'dialog'
    return
  fi

  if command -v whiptail >/dev/null 2>&1; then
    printf 'whiptail'
    return
  fi

  printf 'plain'
}

tui_info() {
  local title="$1"
  local message="$2"
  case "$(_tui_backend)" in
    dialog)
      dialog --title "${title}" --msgbox "${message}" 12 72
      ;;
    whiptail)
      whiptail --title "${title}" --msgbox "${message}" 12 72
      ;;
    *)
      printf '\n== %s ==\n%s\n\n' "${title}" "${message}"
      ;;
  esac
}

tui_pause() {
  local message="${1:-Pressione Enter para continuar.}"
  case "$(_tui_backend)" in
    dialog)
      dialog --title "Continuar" --msgbox "${message}" 10 60
      ;;
    whiptail)
      whiptail --title "Continuar" --msgbox "${message}" 10 60
      ;;
    *)
      printf '\n%s\n' "${message}"
      read -r -p 'Pressione Enter para continuar... ' _
      ;;
  esac
}

tui_menu() {
  local title="$1"
  local prompt="$2"
  shift 2

  local backend
  backend="$(_tui_backend)"

  case "${backend}" in
    dialog)
      local tmp_file
      tmp_file="$(mktemp)"
      dialog --clear --stdout --title "${title}" --menu "${prompt}" 20 90 10 "$@" >"${tmp_file}"
      cat "${tmp_file}"
      rm -f "${tmp_file}"
      ;;
    whiptail)
      whiptail --title "${title}" --menu "${prompt}" 20 90 10 "$@" 3>&1 1>&2 2>&3
      ;;
    *)
      printf '\n== %s ==\n%s\n' "${title}" "${prompt}"
      local index=1
      local tags=()
      while [[ $# -gt 1 ]]; do
        local tag="$1"
        local description="$2"
        printf '  %s) %s - %s\n' "${index}" "${tag}" "${description}"
        tags+=("${tag}")
        shift 2
        index=$((index + 1))
      done
      printf '  0) quit\n'
      local selection
      read -r -p 'Escolha uma opcao: ' selection
      if [[ -z "${selection}" || "${selection}" == "0" ]]; then
        printf 'quit'
      elif [[ "${selection}" =~ ^[0-9]+$ ]] && (( selection >= 1 && selection <= ${#tags[@]} )); then
        printf '%s' "${tags[$((selection - 1))]}"
      else
        printf ''
      fi
      ;;
  esac
}
