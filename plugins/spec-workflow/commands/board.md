---
name: spec-board
description: Exibe um resumo formatado do backlog, organizando tarefas por status e apresentando estatísticas detalhadas do projeto.
version: 2.0.0
category: workflow
triggers:
  - "/spec-board"
  - "mostrar quadro kanban"
  - "visualizar backlog"
  - "ver quadro de tarefas"
  - "board"
---

# Spec-Board: Resumo do Backlog e Estatísticas

Este comando gera uma visualização estruturada do backlog, utilizando ferramentas CLI não-interativas para extrair dados do `Backlog.md`. Ele organiza as tarefas por status e fornece métricas quantitativas do projeto.

## Workflow de Execução

### Passo 1: Obter Estatísticas Gerais

O primeiro passo é obter a visão geral do projeto para extrair métricas de progresso.

```bash
backlog overview
```

### Passo 2: Listar Tarefas por Status

Para construir o "board" formatado, as tarefas devem ser listadas em modo texto plano. O comando suporta filtros para refinar o resultado.

**Comando básico:**
```bash
backlog task list --plain
```

**Com filtros (Passados via argumentos):**
```bash
# Por Milestone
backlog task list --plain --milestone "v1.0 - MVP"

# Por Label
backlog task list --plain --label "bug"

# Por Assignee
backlog task list --plain --assignee "@Claude"

# Por Prioridade
backlog task list --plain --priority "high"
```

### Passo 3: Processamento e Formatação do Output

O output do comando `backlog task list --plain` deve ser processado para gerar uma visualização Markdown amigável.

#### Mapeamento de Prioridades
- 🔴 **critical**: Erros fatais ou bloqueios imediatos.
- 🟠 **high**: Funcionalidades críticas ou bugs importantes.
- 🟡 **medium**: Evoluções planejadas e melhorias.
- 🟢 **low**: Ajustes menores e débitos técnicos.

#### Agrupamento por Status
As tarefas devem ser agrupadas sob os seguintes cabeçalhos (seguindo a ordem natural do fluxo):
1. **TO DO**
2. **IN PROGRESS**
3. **IN REVIEW**
4. **DONE**
5. **BLOCKED** (Sinalizar com ⚠️)

## Exemplo de Saída Formatada

📊 **Backlog Board: [Nome do Projeto]**
_Gerado em: 2026-01-11_

---

### 📈 Estatísticas do Projeto (via `backlog overview`)
- **Total de Tasks:** 24
- **Completas:** 12 (50%)
- **Em Aberto:** 8 (33%)
- **Bloqueadas:** 4 (17%)

---

### 📋 Tarefas Ativas

#### 🏗️ IN PROGRESS (2 tasks)
- 🟠 **task-45**: Implementar autenticação OAuth2 (@Claude) `backend` `auth`
- 🟡 **task-47**: Refatorar componentes de UI (@User) `frontend`

#### 📝 TO DO (3 tasks)
- 🔴 **task-42**: Corrigir vazamento de memória em produção (@Claude) `bug` `critical`
- 🟠 **task-48**: Criar testes de integração para API (@Claude) `testing`
- 🟢 **task-50**: Atualizar README com instruções de deploy `docs`

#### ⚠️ BLOCKED (1 task)
- 🟡 **task-49**: Integração com API de Terceiros (@Claude) `waiting-api`
  _Motivo: Aguardando credenciais de sandbox_

#### ✅ DONE (Últimas 5 tasks)
- 🟢 **task-40**: Setup do ambiente de testes
- 🟡 **task-38**: Implementar log de auditoria

---

## Filtros Suportados

O comando `/spec-board` aceita os seguintes argumentos opcionais para filtrar a lista de tarefas:

- `--milestone <nome>`: Filtra tarefas de um milestone específico.
- `--label <nome>`: Filtra tarefas que possuam a label informada.
- `--assignee <nome>`: Filtra tarefas atribuídas a um membro específico (ex: @Claude).
- `--priority <nível>`: Filtra por prioridade (critical, high, medium, low).

## Quando Usar?

- **Daily Standups**: Para visualizar rapidamente o que está em progresso e o que está bloqueado.
- **Sprint Planning**: Para revisar o que ainda está no "To Do" de um determinado milestone.
- **Status Report**: Para gerar um resumo rápido do estado do projeto para stakeholders.
- **Identificação de Gargalos**: Para ver se há muitas tasks acumuladas em "In Review" ou "Blocked".

## Notas Importantes

- **Não-Interativo**: Este comando foi projetado para ser executado pelo Claude Code, retornando texto que pode ser lido e processado.
- **Backlog.md como Fonte**: Toda a informação provém do arquivo `Backlog.md` gerenciado pelo MCP.
- **Sincronização**: Certifique-se de que o backlog está alinhado com o estado atual do código antes de gerar o board (use `/spec-align` se necessário).
- **Emojis**: O uso de emojis é encorajado para facilitar a leitura rápida da prioridade e status.
