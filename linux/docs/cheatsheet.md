# Linux Troubleshooting Cheat Sheet (v2)

![Trobleshoot](../_images/Troubleshooter.png)

Cheat sheet oficial do projeto `troubleshooter`:

- o projeto **automatiza** comandos de troubleshooting amplamente conhecidos;
- os mesmos comandos podem ser executados **manualmente** e de forma isolada;
- a coleta antes/depois de mudancas gera evidencia e controle de impacto.


## Comandos automatizados por assunto

Legenda de perfil:

- `⚡` = quick
- `🧭` = standard
- `🔬` = deep

### Contexto do host (`context`)

| Perfil | Comando | O que faz (titulo breve) | Exemplo de execucao isolada |
|---|---|---|---|
| ⚡🧭🔬 | `date` | Data/hora atual do servidor | `date` |
| ⚡🧭🔬 | `uname -a` | Kernel e arquitetura | `uname -a` |
| ⚡🧭🔬 | `cat /etc/os-release` | Identificacao da distribuicao | `cat /etc/os-release` |
| ⚡🧭🔬 | `hostnamectl` | Metadados do host | `hostnamectl` |
| ⚡🧭🔬 | `uptime` | Uptime e carga | `uptime` |
| ⚡🧭🔬 | `who` | Usuarios logados | `who` |
| ⚡🧭🔬 | `last -x \| head -n 50` | Boots e mudancas recentes de runlevel | `last -x \| head -n 50` |
| 🧭/🔬 | `timedatectl` | Timezone e sincronizacao de tempo | `timedatectl` |

### Boot e kernel (`boot_kernel`)

| Perfil | Comando | O que faz (titulo breve) | Exemplo de execucao isolada |
|---|---|---|---|
| ⚡🧭🔬 | `journalctl -xb -p warning --no-pager` | Warnings do boot atual | `journalctl -xb -p warning --no-pager` |
| ⚡🧭🔬 | `dmesg -T \| tail -n 120` | Ring buffer recente do kernel | `dmesg -T \| tail -n 120` |
| 🔬 | `lsmod` | Modulos de kernel carregados | `lsmod` |
| 🔬 | `systemd-analyze blame` | Unidades lentas no boot | `systemd-analyze blame` |
| 🔬 | `systemd-analyze critical-chain` | Cadeia critica de inicializacao | `systemd-analyze critical-chain` |

### Servicos (`services`)

| Perfil | Comando | O que faz (titulo breve) | Exemplo de execucao isolada |
|---|---|---|---|
| ⚡🧭🔬 | `systemctl list-units --failed --no-pager` | Unidades systemd em falha | `systemctl list-units --failed --no-pager` |
| ⚡🧭🔬 | `systemctl list-units --type=service --state=running --no-pager` | Servicos systemd em execucao | `systemctl list-units --type=service --state=running --no-pager` |
| 🧭🔬 | `systemctl list-timers --all --no-pager` | Timers ativos/inativos | `systemctl list-timers --all --no-pager` |
| 🧭🔬 | `systemctl list-unit-files --type=service --no-pager` | Unit files de servico instalados no systemd | `systemctl list-unit-files --type=service --no-pager` |
| 🧭🔬 | `service --status-all` | Estado de servicos em sistemas SysV/upstart compativeis | `service --status-all` |
| 🧭🔬 | `chkconfig --list` | Servicos configurados em sistemas com chkconfig | `chkconfig --list` |
| 🧭🔬 | `initctl list` | Estado de jobs no Upstart | `initctl list` |
| 🧭🔬 | `rc-status -a` | Estado de servicos no OpenRC | `rc-status -a` |
| 🧭🔬 | `sv status /etc/service/*` | Estado de servicos no runit | `sv status /etc/service/*` |
| 🧭🔬 | `s6-rc -a list` | Lista de servicos gerenciados por s6-rc | `s6-rc -a list` |
| 🧭🔬 | `journalctl --disk-usage` | Consumo de disco do journal | `journalctl --disk-usage` |

### CPU e memoria (`cpu_memory`)

| Perfil | Comando | O que faz (titulo breve) | Exemplo de execucao isolada |
|---|---|---|---|
| ⚡🧭🔬 | `free -h` | Visao de memoria | `free -h` |
| ⚡🧭🔬 | `vmstat 1 3` | Amostra de estatisticas de VM | `vmstat 1 3` |
| ⚡🧭/🔬 | `top -b -n 1` | Snapshot de processos consumidores | `top -b -n 1` |
| 🧭🔬 | `mpstat -P ALL 1 3` | Uso de CPU por core | `mpstat -P ALL 1 3` |
| 🧭🔬 | `pidstat 1 3` | CPU/memoria por processo | `pidstat 1 3` |
| 🧭🔬 | `cat /proc/pressure/cpu` | Pressao de CPU (PSI) | `cat /proc/pressure/cpu` |
| 🧭🔬 | `cat /proc/pressure/memory` | Pressao de memoria (PSI) | `cat /proc/pressure/memory` |
| 🧭🔬 | `cat /proc/pressure/io` | Pressao de I/O (PSI) | `cat /proc/pressure/io` |
| 🧭🔬 | `cat /proc/meminfo` | Estatisticas detalhadas de memoria do kernel | `cat /proc/meminfo` |

### Disco (`disk`)

| Perfil | Comando | O que faz (titulo breve) | Exemplo de execucao isolada |
|---|---|---|---|
| ⚡🧭🔬 | `df -hT` | Capacidade e tipo de filesystem | `df -hT` |
| ⚡🧭🔬 | `lsblk -f` | Dispositivos e filesystems | `lsblk -f` |
| ⚡🧭🔬 | `findmnt` | Montagens atuais | `findmnt` |
| 🧭🔬 | `du -xhd1 / 2>/dev/null \| sort -h` | Uso top-level da raiz | `du -xhd1 / 2>/dev/null \| sort -h` |
| 🧭🔬 | `iostat -xz 1 3` | Estatisticas avancadas de I/O | `iostat -xz 1 3` |
| 🔬 | `blkid` (priv.) | Identificadores de filesystem | `sudo -n blkid` |
| 🔬 | `smartctl -H /dev/sda` (priv.) | Saude SMART de disco | `sudo -n smartctl -H /dev/sda` |
| 🔬 | `pvs` (priv.) | Volumes fisicos LVM | `sudo -n pvs` |
| 🔬 | `vgs` (priv.) | Grupos de volumes LVM | `sudo -n vgs` |
| 🔬 | `lvs` (priv.) | Volumes logicos LVM | `sudo -n lvs` |

### Rede (`network`)

| Perfil | Comando | O que faz (titulo breve) | Exemplo de execucao isolada |
|---|---|---|---|
| ⚡🧭🔬 | `ss -tulpn` | Sockets e processos ouvindo | `ss -tulpn` |
| ⚡🧭🔬 | `ip -br a` | Interfaces e IPs resumidos | `ip -br a` |
| ⚡🧭🔬 | `ip route` | Tabela de rotas | `ip route` |
| ⚡🧭🔬 | `resolvectl status` | Estado do resolvedor DNS | `resolvectl status` |
| 🧭🔬 | `ss -s` | Resumo de sockets | `ss -s` |
| 🧭🔬 | `ip rule` | Regras de roteamento | `ip rule` |
| 🧭🔬 | `ip neigh` | Tabela ARP/neighbors | `ip neigh` |
| 🧭🔬 | `nft list ruleset` (priv.) | Regras nftables | `sudo -n nft list ruleset` |
| 🧭🔬 | `iptables-save` (priv.) | Regras iptables | `sudo -n iptables-save` |
| 🧭🔬 | `cat /etc/resolv.conf` | Arquivo de configuracao do resolver DNS | `cat /etc/resolv.conf` |
| 🧭🔬 | `cat /etc/hosts` | Hosts estáticos | `cat /etc/hosts` |
| 🧭🔬 | `cat /etc/nsswitch.conf` | Ordem de resolução de nomes | `cat /etc/nsswitch.conf` |
| 🧭🔬 | `cat /etc/network/interfaces` | Interfaces (Debian/Ubuntu) | `cat /etc/network/interfaces` |
| 🧭🔬 | `cat /etc/netplan/*.yaml` | Netplan (Ubuntu) | `cat /etc/netplan/*.yaml` |
| 🧭🔬 | `cat /etc/sysconfig/network-scripts/ifcfg-*` | Scripts de rede (RHEL/CentOS) | `cat /etc/sysconfig/network-scripts/ifcfg-*` |
| 🧭🔬 | `cat /etc/NetworkManager/NetworkManager.conf` | Config principal do NetworkManager | `cat /etc/NetworkManager/NetworkManager.conf` |
| 🧭🔬 | `cat /etc/NetworkManager/system-connections/*` | Perfis do NetworkManager | `cat /etc/NetworkManager/system-connections/*` |
| 🧭🔬 | `cat /etc/firewalld/firewalld.conf` | Config firewalld | `cat /etc/firewalld/firewalld.conf` |
| 🧭🔬 | `firewall-cmd --list-all --permanent` | firewalld (permanente) | `firewall-cmd --list-all --permanent` |
| 🧭🔬 | `firewall-cmd --list-all` | firewalld (runtime) | `firewall-cmd --list-all` |
| 🧭🔬 | `ufw status verbose` | Status do UFW | `ufw status verbose` |
| 🧭🔬 | `nmcli general status` | Status geral do NetworkManager | `nmcli general status` |
| 🧭🔬 | `nmcli device status` | Status de dispositivos NetworkManager | `nmcli device status` |
| 🧭🔬 | `ifconfig -a` | Interfaces (legacy) | `ifconfig -a` |
| 🧭🔬 | `route -n` | Rotas (legacy) | `route -n` |
| 🧭🔬 | `dig +short -x 127.0.0.1` | Teste reverso DNS | `dig +short -x 127.0.0.1` |
| 🧭🔬 | `dig +short google.com` | Teste DNS externo | `dig +short google.com` |
| 🧭🔬 | `nslookup google.com` | Teste DNS via nslookup | `nslookup google.com` |
| 🔬 | `for dev in $(ls /sys/class/net); do ... ethtool ...; done` (priv.) | Features por interface de rede | `for dev in $(ls /sys/class/net); do echo "### $dev ###"; sudo -n ethtool "$dev"; echo; done` |

### Processos (`processes`)

| Perfil | Comando | O que faz (titulo breve) | Exemplo de execucao isolada |
|---|---|---|---|
| ⚡🧭🔬 | `ps auxwwf` | Snapshot completo de processos | `ps auxwwf` |
| 🧭🔬 | `pstree -alp` | Arvore de processos com argumentos | `pstree -alp` |

### Arquivos e locks (`files_locks`)

| Perfil | Comando | O que faz (titulo breve) | Exemplo de execucao isolada |
|---|---|---|---|
| ⚡🧭🔬 | `lsof -nP` | Arquivos/sockets abertos | `lsof -nP` |
| 🧭🔬 | `cat /proc/sys/fs/file-nr` | Contador de file handles do kernel | `cat /proc/sys/fs/file-nr` |

### Logs (`logs`)

| Perfil | Comando | O que faz (titulo breve) | Exemplo de execucao isolada |
|---|---|---|---|
| 🧭🔬 | `journalctl -p warning --since '1 hour ago' --no-pager` | Warnings da ultima hora | `journalctl -p warning --since '1 hour ago' --no-pager` |
| 🧭🔬 | `journalctl -n 300 --no-pager` | Ultimas 300 linhas do journal | `journalctl -n 300 --no-pager` |
| 🧭🔬 | `tail -n 200 /var/log/syslog` | Tail do syslog (quando existir) | `tail -n 200 /var/log/syslog` |
| 🧭🔬 | `tail -n 200 /var/log/messages` | Tail do messages (quando existir) | `tail -n 200 /var/log/messages` |
| 🧭🔬 | `tail -n 200 /var/log/auth.log` | Tail do auth.log (quando existir) | `tail -n 200 /var/log/auth.log` |

### Automacao (`automation`)

| Perfil | Comando | O que faz (titulo breve) | Exemplo de execucao isolada |
|---|---|---|---|
| 🧭🔬 | `ls -la /etc/cron.*` | Itens de cron por diretorio | `ls -la /etc/cron.*` |
| 🧭🔬 | `cat /etc/crontab` | Crontab global do sistema | `cat /etc/crontab` |
| 🧭🔬 | `cat /etc/anacrontab` | Agenda do anacron (quando existir) | `cat /etc/anacrontab` |
| 🧭🔬 | `ls -la /var/spool/cron /var/spool/cron/crontabs 2>/dev/null` | Spool de crontabs por usuario | `ls -la /var/spool/cron /var/spool/cron/crontabs` |
| 🧭🔬 | `crontab -l` | Crontab do usuario atual | `crontab -l` |
| 🧭🔬 | `crontab -u root -l` (priv.) | Crontab do usuario root | `sudo -n crontab -u root -l` |
| 🧭🔬 | `for user in $(getent passwd ...); do crontab -u "$user" -l; done` (priv.) | Crontab de todos os usuarios locais | `sudo -n bash -lc 'for user in $(getent passwd | cut -d: -f1); do echo "### $user ###"; crontab -u "$user" -l 2>&1 || true; echo; done'` |
| 🧭🔬 | `atq` | Jobs enfileirados no at/batch | `atq` |
| 🧭🔬 | `cat /etc/at.allow /etc/at.deny 2>/dev/null` | Controle de permissao do at | `cat /etc/at.allow /etc/at.deny` |
| 🧭🔬 | `ls -la /etc/periodic/* 2>/dev/null` | Diretórios de jobs periódicos (Alpine/BusyBox) | `ls -la /etc/periodic/*` |

### Containers (`containers`)

| Perfil | Comando | O que faz (titulo breve) | Exemplo de execucao isolada |
|---|---|---|---|
| 🧭🔬 | `docker ps -a` | Containers Docker | `docker ps -a` |
| 🧭🔬 | `podman ps -a` | Containers Podman | `podman ps -a` |

### Seguranca/config (`security`)

| Perfil | Comando | O que faz (titulo breve) | Exemplo de execucao isolada |
|---|---|---|---|
| 🔬 | `find /etc -type f -mtime -7 2>/dev/null \| sort \| head -n 300` | Mudancas recentes em `/etc` | `find /etc -type f -mtime -7 2>/dev/null \| sort \| head -n 300` |
| 🔬 | `grep -R -n -E 'Listen\|Port' /etc 2>/dev/null \| head -n 300` | Configs com Listen/Port | `grep -R -n -E 'Listen\|Port' /etc 2>/dev/null \| head -n 300` |
| 🔬 | `bash -lc 'getent passwd \| while ...; do ... history files ...; done'` (priv.) | Historico de comandos de todos os usuarios (bash/zsh/fish/ash/sh), com opcao de mascaramento | `TROUBLESHOOTER_MASK_SENSITIVE=1 sudo -n bash -lc 'getent passwd | while IFS=: read -r user _ uid _ _ home shell; do [ -d "$home" ] || continue; echo "### $user ###"; for h in "$home/.bash_history" "$home/.zsh_history" "$home/.local/share/fish/fish_history" "$home/.ash_history" "$home/.sh_history"; do [ -r "$h" ] && { echo "--- $h ---"; tail -n 200 "$h"; echo; }; done; done'` |

### Pacotes instalados (`packages`)

| Perfil | Comando | O que faz (titulo breve) | Exemplo de execucao isolada |
|---|---|---|---|
| 🔬 | `dpkg -l 2>/dev/null \| sort` | Pacotes instalados (Debian/Ubuntu) | `dpkg -l \| sort` |
| 🔬 | `rpm -qa 2>/dev/null \| sort` | Pacotes instalados (RHEL/CentOS/Fedora) | `rpm -qa \| sort` |
| 🔬 | `apt list --installed 2>/dev/null` | Pacotes instalados via apt | `apt list --installed 2>/dev/null` |
| 🔬 | `dnf list installed 2>/dev/null` | Pacotes instalados via dnf | `dnf list installed 2>/dev/null` |
| 🔬 | `zypper packages --installed-only 2>/dev/null` | Pacotes instalados (openSUSE/SLES) | `zypper packages --installed-only` |
| 🔬 | `apk list --installed 2>/dev/null` | Pacotes instalados (Alpine Linux) | `apk list --installed` |
| 🔬 | `npm list -g --depth=0 2>/dev/null` | Pacotes npm globais | `npm list -g --depth=0` |
| 🔬 | `pip3 list --format=columns 2>/dev/null` | Pacotes Python instalados | `pip3 list --format=columns` |
| 🔬 | `go env` | Ambiente e versao do runtime Go | `go env` |
| 🔬 | `cargo install --list 2>/dev/null` | Pacotes Rust instalados via cargo | `cargo install --list` |

### Hardware (`hardware`)

| Perfil | Comando | O que faz (titulo breve) | Exemplo de execucao isolada |
|---|---|---|---|
| 🔬 | `lspci` | Dispositivos PCI conectados | `lspci` |
| 🔬 | `lsusb` | Dispositivos USB conectados | `lsusb` |
| 🔬 | `dmidecode` (priv.) | Informacoes de hardware e BIOS (DMI/SMBIOS) | `sudo -n dmidecode` |
| 🔬 | `getent passwd` | Contas locais/remotas visiveis | `getent passwd` |

