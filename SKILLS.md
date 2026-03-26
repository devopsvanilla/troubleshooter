# SKILLS.md

Catálogo de competências e padrões de evolução do repositório `troubleshooter`.

Este arquivo não descreve “skills” de uma plataforma específica; ele organiza as capacidades do projeto para orientar manutenção, expansão e automação futura.

## Visão geral

O projeto hoje tem uma competência principal implementada e várias competências-alvo previstas.

### Já implementado

- **capture-state** — coleta inicial do estado do host com persistência estruturada.

### Planejado

- **live-observe** — observação rápida em tempo real;
- **service-drilldown** — aprofundamento por serviço específico;
- **network-triage** — triagem de rede com testes parametrizados;
- **snapshot-compare** — comparação entre capturas;
- **export-bundle** — empacotamento da sessão para compartilhamento.

## Skill 1 — Capture state

### Propósito

Realizar uma fotografia operacional do servidor no início da sessão de troubleshooting.

### Entradas

- perfil de coleta: `quick`, `standard` ou `deep`;
- diretório atual de execução;
- disponibilidade de comandos no host;
- disponibilidade de `sudo -n`.

### Saídas

- `./start-session/state/<timestamp>/summary.md`
- `./start-session/state/<timestamp>/manifest.json`
- `./start-session/state/<timestamp>/commands/*.log`

### Regras

- não falhar a sessão inteira por conta de um comando isolado;
- registrar `ok`, `failed`, `timeout`, `missing_dependency` ou `needs_sudo`;
- manter um arquivo por comando;
- preservar descrição, timeout, exit code, `stdout` e `stderr`.

### Arquivos principais

- `linux/modules/capture_state.sh`
- `linux/lib/runner.sh`
- `linux/lib/output.sh`

## Skill 2 — TUI resiliente

### Propósito

Fornecer uma interface usável tanto em hosts completos quanto em ambientes mínimos.

### Modos suportados

- `dialog`
- `whiptail`
- fallback textual

### Regras

- nenhum menu novo pode depender exclusivamente de `dialog`;
- o fallback textual deve permanecer funcional;
- mensagens precisam ser curtas, objetivas e operacionais.

### Arquivo principal

- `linux/lib/tui.sh`

## Skill 3 — Execução segura de comandos

### Propósito

Executar comandos do sistema com observabilidade e risco controlado.

### Requisitos

- timeout por comando;
- captura separada de `stdout` e `stderr`;
- medição simples de duração;
- detecção de comando ausente;
- tratamento explícito de privilégio.

### Regras

- nunca assumir root por padrão;
- privilegiado deve ser marcado explicitamente;
- não usar shell pipelines destrutivos ou side effects sem justificativa.

### Arquivo principal

- `linux/lib/runner.sh`

## Skill 4 — Persistência e rastreabilidade

### Propósito

Garantir que a coleta gere artefatos úteis para análise posterior e colaboração.

### Requisitos

- diretório por sessão;
- nomes de arquivo estáveis e ordenáveis;
- manifesto agregador estruturado;
- resumo humano legível.

### Regras

- toda nova habilidade que produzir coleta deve seguir o mesmo padrão de sessão;
- evite formatos opacos quando texto simples ou JSON resolverem;
- preserve retrocompatibilidade quando possível.

### Arquivo principal

- `linux/lib/output.sh`

## Skill 5 — Design de catálogo de comandos

### Propósito

Selecionar e organizar comandos úteis sem transformar a ferramenta em uma coleira de ruído.

### Critérios de inclusão

Um comando novo deve ser:

- relevante para troubleshooting;
- seguro por padrão;
- portátil o suficiente ou claramente opcional;
- compreensível no artefato gerado.

### Critérios de exclusão ou cautela

Evitar por padrão comandos que sejam:

- destrutivos;
- muito lentos sem necessidade;
- excessivamente verbosos;
- propensos a vazar dados sensíveis.

### Perfis

- `quick` — essencial, baixo impacto;
- `standard` — recomendado para uso geral;
- `deep` — ampliado, mais caro ou mais verboso.

### Arquivo principal

- `linux/modules/capture_state.sh`

## Skill 6 — Documentação operacional

### Propósito

Manter o projeto fácil de entender para humanos e agentes futuros.

### Requisitos mínimos ao evoluir o repositório

Ao adicionar uma funcionalidade relevante, atualizar:

- `README.md` se o uso mudou;
- `linux/docs/architecture.md` se o contrato mudou;
- `linux/docs/commands.md` se o catálogo mudou;
- `AGENTS.md` ou `SKILLS.md` se a governança ou taxonomia mudarem.

## Matriz de expansão sugerida

| Skill futura | Valor operacional | Complexidade | Prioridade |
|---|---:|---:|---:|
| `service-drilldown` | Alta | Média | Alta |
| `network-triage` | Alta | Média | Alta |
| `export-bundle` | Média | Baixa | Alta |
| `snapshot-compare` | Alta | Média | Média |
| `live-observe` | Média | Média | Média |
| `container-triage` | Média | Média | Média |
| `kubernetes-triage` | Alta | Alta | Baixa |

## Definição de pronto para uma nova skill

Uma nova competência só deve ser considerada pronta quando:

1. estiver integrada ao fluxo principal ou ao menu;
2. tiver validação básica executada;
3. gerar saída clara e rastreável;
4. tiver documentação mínima de uso;
5. respeitar as regras de segurança operacional do projeto.

## Exemplo de como adicionar uma skill nova

### Exemplo: `service-drilldown`

1. Criar `linux/modules/service_drilldown.sh`.
2. Expor uma função principal como `service_drilldown_main`.
3. Reaproveitar `linux/lib/tui.sh`, `linux/lib/runner.sh` e `linux/lib/output.sh`.
4. Conectar o menu em `linux/bin/troubleshooter`.
5. Atualizar `README.md`, `AGENTS.md` e `linux/docs/architecture.md`.
6. Validar com `bash -n` e smoke test manual.

## Skill anti-padrão: o que não queremos cultivar

- acoplamento forte entre módulos;
- lógica crítica escondida dentro do entrypoint;
- dependências obrigatórias difíceis de instalar;
- comandos destrutivos em nome de “diagnóstico rápido”; 
- comportamento diferente demais entre TUI bonita e fallback textual.

## Resumo prático

Se for expandir este repositório, pense em cada funcionalidade como uma competência separada com:

- objetivo claro;
- entrada definida;
- saída rastreável;
- baixo risco operacional;
- documentação enxuta e útil.

Essa disciplina é o que vai impedir o projeto de virar uma caixa de surpresas mal-humorada.
