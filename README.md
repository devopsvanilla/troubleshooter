# troubleshooter

[![ShellCheck](https://github.com/devopsvanilla/troubleshooter/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/devopsvanilla/troubleshooter/actions/workflows/shellcheck.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Shell](https://img.shields.io/badge/shell-bash-blue)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey)

![Troubleshoot](./linux/_images/Troubleshooter.png)

Toolkit de troubleshooting Linux com foco em coleta estruturada de evidencias para diagnostico seguro e orientado por dados.

## Motivacao

Em ambientes reais, alterar configuracoes, atualizar pacotes ou ajustar servicos sem uma linha de base confiavel aumenta o risco de incidentes e dificulta a analise de causa raiz.

Por isso, a coleta do estado do sistema operacional **antes** de qualquer mudanca e essencial: ela registra o contexto tecnico do host no momento da investigacao e cria evidencias objetivas para auditoria, comparacao e tomada de decisao.

Da mesma forma, repetir a captura **apos** as alteracoes permite medir o impacto das acoes executadas, validar se o resultado esperado foi atingido e reduzir incertezas em rollback, handover e post-mortem.

Em resumo: capturar antes e depois transforma troubleshooting em um processo mais previsivel, rastreavel e com menor risco operacional.

O MVP atual entrega:

- menu TUI com `dialog`, `whiptail` ou fallback textual;
- acao `capture-state` para snapshot inicial do host;
- armazenamento da sessao em `./start-session/state/<timestamp>/`;
- um arquivo por comando em `commands/`;
- `manifest.json` com metadados estruturados;
- `summary.md` com visao rapida dos resultados;
- coleta ampliada de rede: arquivos de configuração (`/etc/hosts`, `nsswitch.conf`, `netplan`, `NetworkManager`, firewalls, etc.), comandos de diagnóstico e status de interfaces para múltiplas distribuições.

Guias de manutencao:

- `AGENTS.md` — regras operacionais para agentes e contribuidores;
- `SKILLS.md` — catalogo de capacidades atuais e futuras do projeto;
- `CONTRIBUTING.md` — como contribuir com o projeto.

## Inspiracao e ferramentas similares

Este projeto foi inspirado por abordagens e utilitarios ja conhecidos no ecossistema Linux, especialmente para coleta inicial de diagnostico:

- `sosreport` / `sos` — coleta abrangente de informacoes para suporte tecnico ([site oficial](https://github.com/sosreport/sos));
- `supportconfig` — ferramenta de coleta automatizada (comum em SUSE) ([site oficial](https://github.com/openSUSE/supportutils));
- `sysstat` (`sar`, `iostat`, `mpstat`) — visao historica e pontual de performance ([site oficial](https://github.com/sysstat/sysstat));
- `collectl` — coleta continua de metricas de sistema ([site oficial](http://collectl.sourceforge.net/));
- `cockpit` — administracao e observabilidade via interface web ([site oficial](https://cockpit-project.org/));
- `netdata` — monitoramento em tempo real com foco em visibilidade rapida ([site oficial](https://www.netdata.cloud/));
- `lnav` — navegacao e analise de logs em terminal ([site oficial](https://lnav.org/)).

O objetivo aqui nao e substituir integralmente essas ferramentas, mas oferecer um fluxo simples, seguro e modular de "start-session" para troubleshooting operacional.

## Cheat sheet do projeto

Para material de divulgacao e uso rapido (incluindo versao base para imagem), veja:

- `linux/docs/cheatsheet.md` — comandos automatizados por assunto, o que cada um faz e exemplo de execucao isolada.

## Estrutura

- `AGENTS.md` — guia de governanca e fluxo de manutencao
- `SKILLS.md` — mapa de competencias e expansao do projeto
- `CONTRIBUTING.md` — guia de contribuicao
- `linux/bin/troubleshooter` — entrypoint principal
- `linux/lib/` — funcoes compartilhadas (TUI, execucao, persistencia)
- `linux/modules/` — modulos de funcionalidades do menu
- `linux/docs/` — documentacao tecnica e catalogo de comandos

## Dependencias

Obrigatorias:

- `bash`
- `coreutils`

Opcionais, mas recomendadas:

- `dialog` ou `whiptail` para TUI mais amigavel
- `sudo` para coletas privilegiadas
- `lsof`, `mpstat`, `pidstat`, `iostat`, `smartctl`, `ethtool`, `docker`, `podman`

## Uso

Interativo:

```bash
./linux/bin/troubleshooter
```

Ao usar o menu interativo (TUI), sera perguntado se deseja tentar executar comandos privilegiados com sudo. Caso aceite, todos os comandos possiveis serao executados com sudo automaticamente (quando disponivel).

Execucao direta da captura:

```bash
./linux/bin/troubleshooter capture-state
```

Perfis disponiveis:

- `quick` — coleta essencial, menor impacto
- `standard` — perfil recomendado
- `deep` — coleta ampliada, pode ser mais lenta

Perfis mais amplos coletam tambem:
- arquivos de configuracao de rede (hosts, nsswitch, netplan, NetworkManager, firewalld, ufw, etc.);
- status de firewalls (`firewalld`, `ufw`), NetworkManager, netplan;
- comandos de diagnostico DNS (`dig`, `nslookup`), rotas (`route`), interfaces (`ifconfig`), alem dos ja existentes (`ip`, `ss`, etc.).

Exemplos:

```bash
./linux/bin/troubleshooter capture-state --profile quick
./linux/bin/troubleshooter --no-tui capture-state --profile deep
./linux/bin/troubleshooter capture-state --profile deep --mask-sensitive
```

Opcao adicional:

- `--mask-sensitive` — mascara padroes comuns de segredo em coletas sensiveis (como historico de comandos multiusuario).

## Politica de privilegios

A ferramenta **nao assume root**. Comandos que exigem privilegios elevados tentam usar `sudo -n` quando disponivel. Caso contrario, o comando e marcado como `needs_sudo`, mas a sessao continua.

## Saida da captura

A partir do diretorio atual da execucao:

- `./start-session/state/<timestamp>/summary.md`
- `./start-session/state/<timestamp>/manifest.json`
- `./start-session/state/<timestamp>/commands/*.log`

Cada arquivo de comando inclui:

- metadados basicos;
- comando executado;
- `stdout`;
- `stderr`;
- exit code;
- duracao.

## Extensao futura

O menu foi preparado para receber novos modulos, como:

- `live-observe`
- `service-drilldown`
- `network-triage`
- comparacao entre snapshots
- export bundle

Veja `linux/docs/architecture.md` para o contrato basico de extensao.

## Contribuindo

Contribuicoes sao bem-vindas! Leia o [CONTRIBUTING.md](CONTRIBUTING.md) para entender o fluxo de trabalho, convencoes de commit e padroes de codigo.

## Licenca

Este projeto e distribuido sob a licenca **MIT**. Veja o arquivo [LICENSE](LICENSE) para os termos completos.
