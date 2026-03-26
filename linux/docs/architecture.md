# Architecture

## Objetivo

Manter o utilitario simples para executar em servidores Linux e, ao mesmo tempo, modular o suficiente para receber novas funcionalidades sem refatoracoes grandes.

## Componentes

- `bin/troubleshooter`
  - bootstrap da aplicacao;
  - parser de argumentos;
  - roteamento para menu ou execucao direta.
- `lib/common.sh`
  - utilitarios de log, deteccao de comandos e helpers genericos.
- `lib/tui.sh`
  - abstracao da interface (`dialog`, `whiptail` ou terminal puro).
- `lib/output.sh`
  - criacao da sessao e escrita dos artefatos.
- `lib/runner.sh`
  - execucao segura dos comandos com timeout e captura de saida.
- `modules/*.sh`
  - funcionalidades do menu.

## Contrato de modulo

Cada modulo deve:

1. ser um arquivo shell em `linux/modules/`;
2. expor uma funcao principal, por exemplo `capture_state_main`;
3. depender apenas das funcoes compartilhadas de `linux/lib/`;
4. ser responsavel por registrar seu proprio catalogo de acoes ou comandos;
5. evitar efeitos destrutivos por padrao.

## Convencoes para novas funcionalidades

- prefira perfis de coleta (`quick`, `standard`, `deep`) quando a operacao puder ser custosa;
- marque comandos privilegiados explicitamente;
- trate dependencias ausentes como `best effort`;
- escreva artefatos sempre dentro da sessao ativa;
- nao interrompa a sessao inteira por falha isolada.

## Estrutura de saida

Cada execucao cria:

- `start-session/state/<timestamp>/summary.md`
- `start-session/state/<timestamp>/manifest.json`
- `start-session/state/<timestamp>/commands/*.log`

## Direcao de crescimento sugerida

1. menu de observacao ao vivo;
2. drill-down por servico systemd;
3. triagem de rede com testes parametrizados;
4. comparacao entre snapshots;
5. exportacao compactada da sessao.
