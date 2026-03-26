# AGENTS.md

Guia operacional para agentes, mantenedores e contribuidores do repositório `troubleshooter`.

## Objetivo do repositório

Este projeto existe para criar um toolkit de troubleshooting Linux com foco em:

- captura inicial de evidências antes do diagnóstico manual;
- execução segura em servidores reais;
- baixa dependência e alta portabilidade;
- arquitetura modular para crescimento incremental.

O MVP atual é baseado em **Bash**, com:

- TUI opcional via `dialog` ou `whiptail`;
- fallback textual quando essas dependências não existirem;
- funcionalidade principal `capture-state`;
- saída estruturada em `./start-session/state/<timestamp>/`.

## Missão de quem atuar neste repositório

Ao trabalhar aqui, priorize sempre:

1. **segurança operacional** — não introduzir ações destrutivas por padrão;
2. **portabilidade** — manter compatibilidade com distribuições Linux comuns;
3. **diagnóstico útil** — coletar informação acionável, não ruído infinito;
4. **extensibilidade** — novas funcionalidades devem entrar como módulos previsíveis;
5. **tolerância a falhas** — ausência de comandos ou privilégios não deve quebrar a sessão.

## Estado atual do projeto

### Implementado

- `linux/bin/troubleshooter` — entrypoint principal;
- `linux/lib/common.sh` — utilitários gerais;
- `linux/lib/tui.sh` — abstração de interface;
- `linux/lib/output.sh` — criação de sessão e artefatos;
- `linux/lib/runner.sh` — execução segura com timeout;
- `linux/modules/capture_state.sh` — catálogo e orquestração da captura;
- `README.md` — visão geral e uso;
- `linux/docs/architecture.md` — contrato de módulos;
- `linux/docs/commands.md` — visão do catálogo de coleta.

### Próximas frentes naturais

- `live-observe`
- `service-drilldown`
- `network-triage`
- comparação entre snapshots
- exportação compactada da sessão

## Mapa do repositório

```text
.
├── AGENTS.md
├── SKILLS.md
├── README.md
├── linux/
│   ├── bin/
│   │   └── troubleshooter
│   ├── docs/
│   │   ├── architecture.md
│   │   └── commands.md
│   ├── lib/
│   │   ├── common.sh
│   │   ├── output.sh
│   │   ├── runner.sh
│   │   └── tui.sh
│   ├── modules/
│   │   └── capture_state.sh
│   └── _images/
└── .gitignore
```

## Acordos de manutenção

### 1. Não transformar o projeto em um canivete suíço radioativo

Evite:

- remediação automática por padrão;
- alterações de configuração no host durante captura;
- comandos destrutivos, intrusivos ou longos sem opt-in explícito;
- acoplamento forte entre TUI, executor e catálogo de coleta.

### 2. Prefira crescimento modular

Ao adicionar algo novo:

- crie ou atualize um módulo em `linux/modules/`;
- reaproveite `linux/lib/` para lógica compartilhada;
- mantenha o `bin/troubleshooter` fino, como orquestrador;
- documente a nova funcionalidade em `README.md` e, se necessário, em `linux/docs/`.

### 3. Preserve o contrato de saída

A estrutura de artefatos gerada por sessão é parte importante do projeto.

Cada execução deve continuar produzindo, no mínimo:

- `summary.md`
- `manifest.json`
- `commands/*.log`

Mudanças no formato devem ser:

- justificadas;
- retrocompatíveis quando possível;
- documentadas explicitamente.

### 4. Comandos privilegiados são opt-in técnico, não pressuposto

A ferramenta **não deve assumir root**.

Regras:

- tente `sudo -n` quando necessário;
- registre `needs_sudo` se privilégio não estiver disponível;
- não trave a sessão por falta de permissão em um comando isolado.

### 5. Best effort acima de rigidez excessiva

Em servidores reais, é esperado que:

- `smartctl` não exista;
- `docker` ou `podman` não estejam instalados;
- `journalctl` exista mas retorne resultados diferentes por distro;
- alguns arquivos de log simplesmente não existam.

Esse comportamento deve ser tratado como parte normal do fluxo.

## Fluxo recomendado para qualquer mudança

1. Entender a intenção da funcionalidade ou correção.
2. Ler os arquivos relevantes em `README.md`, `linux/docs/` e `linux/lib/`.
3. Planejar a mudança de forma pequena e testável.
4. Implementar no módulo ou helper correto.
5. Validar sintaxe shell com `bash -n`.
6. Rodar smoke test da funcionalidade alterada.
7. Atualizar documentação.

## Checklist de validação

Antes de considerar uma alteração pronta, validar:

- `bash -n linux/bin/troubleshooter linux/lib/*.sh linux/modules/*.sh`
- `./linux/bin/troubleshooter --help`
- `./linux/bin/troubleshooter capture-state --profile quick`

Quando a mudança tocar catálogo, runner, saída ou TUI, também validar:

- `./linux/bin/troubleshooter capture-state --profile standard`
- parsing do `manifest.json` com `python3 -c` ou script simples;
- fallback com `./linux/bin/troubleshooter --no-tui`

Se `shellcheck` existir no ambiente, use também.

## Convenções de implementação

### Bash

- usar `#!/usr/bin/env bash`;
- habilitar `set -euo pipefail` em entrypoints e scripts executáveis;
- citar variáveis com `"${var}"`;
- evitar lógica complexa duplicada entre módulos;
- preferir funções pequenas e nomes explícitos.

### TUI

- `dialog` e `whiptail` são opcionais;
- o terminal puro é fallback oficial, não gambiarra temporária;
- novos menus devem funcionar nos três modos.

### Catálogo de comandos

Cada coleta deve definir claramente:

- identificador;
- categoria;
- se requer privilégio;
- timeout;
- descrição útil;
- comando real.

### Segurança e privacidade

Evite adicionar por padrão comandos que:

- exfiltram dados sensíveis;
- geram dumps enormes sem controle;
- expõem segredos desnecessariamente;
- alteram estado do sistema.

Se um comando for potencialmente sensível ou caro, prefira deixá-lo em perfil `deep` ou atrás de opt-in futuro.

## Critérios para novas funcionalidades

Uma nova capacidade deve responder positivamente a pelo menos três perguntas:

- ajuda a capturar evidência relevante?
- é segura para execução em produção?
- tem baixo ou médio impacto operacional?
- gera saída clara e reutilizável?
- cabe naturalmente como módulo isolado?

Se não passar nesse filtro, provavelmente ainda não é hora de entrar.

## Backlog orientador

Áreas boas para evolução:

- drill-down por serviço systemd;
- diagnóstico de rede com alvo parametrizado;
- export bundle (`tar.gz`) da sessão;
- comparação entre snapshots;
- catálogo por distro;
- perfis de coleta mais finos;
- filtros/redactions adicionais para dados sensíveis.

## Em caso de dúvida

Se precisar escolher entre:

- uma solução elegante porém frágil; e
- uma solução simples, previsível e segura,

escolha a segunda.

Produção costuma ter zero paciência para brilhantismo instável.
