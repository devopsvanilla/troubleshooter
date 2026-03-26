# Capture-state command catalog

## Perfis

### quick

Coleta essencial com baixo impacto. Ideal para primeira passada em producao.

### standard

Inclui `quick` e adiciona mais contexto de servicos, disco, logs, automacao, containers e rede.

### deep

Inclui `standard` e adiciona itens potencialmente mais caros ou mais verbosos.

## Categorias

- `context`
- `boot_kernel`
- `services`
- `cpu_memory`
- `disk`
- `network`
- `processes`
- `files_locks`
- `logs`
- `automation`
- `containers`
- `security`
- `packages`
- `hardware`

## Observacoes de desenho

- Um arquivo `.log` e gerado por comando.
- Comandos com privilegio elevado sao marcados como `yes` e tentam `sudo -n`.
- Dependencias ausentes nao interrompem a captura.
- Alguns comandos podem falhar dependendo da distro, o que tambem e registrado no artefato.

## Exemplos de comandos incluidos
- `cat /etc/hosts` — hosts estáticos
- `cat /etc/nsswitch.conf` — ordem de resolução de nomes
- `cat /etc/network/interfaces` — interfaces (Debian/Ubuntu)
- `cat /etc/netplan/*.yaml` — netplan (Ubuntu)
- `cat /etc/sysconfig/network-scripts/ifcfg-*` — scripts de rede (RHEL/CentOS)
- `cat /etc/NetworkManager/NetworkManager.conf` — config principal do NetworkManager
- `cat /etc/NetworkManager/system-connections/*` — perfis do NetworkManager
- `cat /etc/firewalld/firewalld.conf` — config firewalld
- `firewall-cmd --list-all --permanent` e `firewall-cmd --list-all` — regras firewalld
- `ufw status verbose` — status do UFW
- `nmcli general status` e `nmcli device status` — status do NetworkManager
- `ifconfig -a` — interfaces (legacy)
- `route -n` — rotas (legacy)
- `dig +short -x 127.0.0.1` e `dig +short google.com` — resolução DNS
- `nslookup google.com` — teste DNS

- `journalctl -xb -p warning --no-pager`
- `dmesg -T | tail -n 120`
- `systemctl list-units --failed --no-pager`
- `systemctl list-units --type=service --state=running --no-pager`
- `free -h`
- `vmstat 1 3`
- `top -b -n 1`
- `df -hT`
- `lsblk -f`
- `ss -tulpn`
- `ip -br a`
- `ps auxwwf`
- `lsof -nP`
- `systemctl list-timers --all --no-pager`
- `systemctl list-unit-files --type=service --no-pager`
- `service --status-all`
- `chkconfig --list`
- `initctl list`
- `rc-status -a`
- `sv status /etc/service/*`
- `s6-rc -a list`
- `cat /etc/crontab`
- `cat /etc/anacrontab`
- `crontab -u root -l`
- `bash -lc 'for user in $(getent passwd | cut -d: -f1); do crontab -u "$user" -l; done'`
- `atq`
- `cat /etc/at.allow /etc/at.deny`
- `ls -la /var/spool/cron /var/spool/cron/crontabs`
- `ls -la /etc/periodic/*`
- `journalctl --disk-usage`
- `mpstat -P ALL 1 3`
- `pidstat 1 3`
- `iostat -xz 1 3`
- `nft list ruleset`
- `iptables-save`
- `docker ps -a`
- `podman ps -a`
- `systemd-analyze critical-chain`
- `smartctl -H /dev/sda`
- `cat /proc/meminfo`
- `cat /etc/resolv.conf`
- `pvs`, `vgs`, `lvs`
- `dpkg -l`, `rpm -qa`, `apt list --installed`, `dnf list installed`, `zypper packages --installed-only`, `apk list --installed`
- `npm list -g --depth=0`
- `pip3 list --format=columns`
- `go env`
- `cargo install --list`
- `lspci`
- `lsusb`
- `dmidecode`
- `bash -lc 'getent passwd | while IFS=: read -r user _ uid _ _ home shell; do ...; done'`

## Comandos futuros recomendados

- `kubectl get pods -A`
- `crictl ps -a`
- `sar -n DEV 1 3`
- `sar -r 1 3`
