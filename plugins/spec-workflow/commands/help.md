---
name: spec-help
description: Exibe ajuda sobre o fluxo de trabalho Spec-Driven Development e lista os comandos disponíveis.
version: 2.0.0
category: workflow
triggers:
  - "/spec-help"
  - "ajuda spec"
  - "comandos spec"
  - "como usar spec"
  - "spec workflow"
---

# Spec-Driven Development: Guia Completo (v2.0)

Este plugin implementa a filosofia **Spec-Driven Development** (Desenvolvimento Guiado por Especificação) integrado 100% com **Backlog.md MCP**, onde a documentação precede e guia o código.

## 🎯 Filosofia

### Princípios Fundamentais

1. **Spec-First**: Toda feature DEVE ter uma Spec antes de implementação
2. **AC Obrigatório**: Toda task DEVE ter Acceptance Criteria verificáveis
3. **MCP-Only**: NUNCA editar arquivos `.backlog` manualmente
4. **Extensão .backlog**: Specs e documentos de padrões DEVEM usar extensão `.backlog`
5. **Revisão Obrigatória**: Código DEVE passar por `/spec-review` antes de `/spec-retro`
6. **Memória Ativa**: Aprendizados críticos DEVEM ser salvos no Basic Memory

### Arquitetura do Sistema

```
Backlog.md MCP (Single Source of Truth)
├── Tasks (task-001.md, task-002.md, ...)
│   ├── Campos: title, type, status, priority, labels, milestone
│   ├── Campos: assignee, dependencies, acceptance_criteria, plan, notes
│   └── Vinculação: Cada task aponta para sua Spec
├── Specs (specs/SPEC-001-feature.backlog)
│   ├── Extensão: .backlog (OBRIGATÓRIA)
│   ├── Conteúdo: Requisitos, arquitetura, ACs, plano técnico
│   └── Versionamento: Campo version no frontmatter
├── Docs de Padrões (docs/standards/*.backlog)
│   ├── Constituição: doc-001 (Regras inegociáveis)
│   ├── Padrões: Código, segurança, arquitetura
│   └── Extensão: .backlog (OBRIGATÓRIA)
└── ADRs (Architecture Decision Records)
    ├── Criadas via backlog_decision_create
    ├── Status: proposed, accepted, rejected, deprecated
    └── Campos: context, decision, consequences, alternatives
```

---

## 📚 Comandos Disponíveis

### 🚀 Inicialização

#### `/spec-init` - Inicializar Ambiente

**Objetivo**: Configurar ambiente Spec-Driven Development com Backlog MCP

**Uso**:
```bash
/spec-init
```

**O que faz**:
1. ✅ Valida instalação do CLI `backlog`
2. ✅ Limpa resquícios de inicializações anteriores
3. ✅ Executa `backlog init "nome-projeto"`
4. ✅ Configura `backlog/config.yml` (statuses, labels, milestones)
5. ✅ Cria Constituição via MCP (`docs/standards/constituicao.backlog`)
6. ✅ Inicializa Basic Memory com nota do projeto
7. ✅ Atualiza CLAUDE.md com regras imperativas

**Quando usar**:
- Início de novo projeto
- Re-inicialização após mudanças estruturais
- Migração de projeto existente para Spec-Driven

---

### 📝 Ciclo de Vida de Features

#### `/spec-plan` - Planejar Nova Feature

**Objetivo**: Criar task macro e spec document para nova feature

**Uso**:
```bash
/spec-plan "Nome da Feature"
```

**O que faz**:
1. ✅ Cria task via `backlog_task_create` com TODOS os campos:
   - `priority`, `labels`, `milestone`, `assignee`
   - `dependencies`, `acceptance_criteria`, `plan`, `notes`
2. ✅ Cria Spec Document em `specs/SPEC-{ID}-{slug}.backlog`
3. ✅ Vincula task à spec
4. ✅ Consulta Basic Memory para evitar duplicação
5. ✅ Registra ADRs se houver decisões arquiteturais

**Saída**:
- Task criada (ex: `task-10`)
- Spec criada (ex: `specs/SPEC-010-sistema-autenticacao.backlog`)
- Plano de implementação com X etapas
- N Acceptance Criteria definidos

**Quando usar**:
- Antes de implementar qualquer nova feature
- Ao iniciar épico ou módulo grande
- Para documentar features complexas

---

#### `/spec-execute` - Executar Task Planejada

**Objetivo**: Guiar implementação de task seguindo sua Spec

**Uso**:
```bash
/spec-execute task-10
# ou
/spec-execute  # Auto-seleciona task em progresso
```

**O que faz**:
1. ✅ Verifica dependências (bloqueia se pendentes)
2. ✅ Lê Spec vinculada à task
3. ✅ Atualiza status para "In Progress"
4. ✅ Cria subtarefas se necessário (campo `parent`)
5. ✅ Lança subagente especializado para implementação
6. ✅ Atualiza `notes` progressivamente durante execução
7. ✅ Marca ACs como concluídos conforme implementa
8. ✅ Muda status para "In Review" ao finalizar

**Saída**:
- Task movida para "In Progress" → "In Review"
- Notas incrementais registradas
- Subtarefas criadas (se aplicável)
- ACs marcados como `[x]`

**Quando usar**:
- Após aprovar spec via `/spec-plan`
- Para retomar task em progresso
- Seguindo ordem de prioridades do backlog

---

#### `/spec-review` - Revisar Conformidade

**Objetivo**: Auditar implementação antes de finalizar

**Uso**:
```bash
/spec-review task-10
```

**O que faz**:
1. ✅ **Valida ACs automaticamente** (bloqueia se `[ ]` pendentes)
2. ✅ Verifica conformidade com Spec
3. ✅ Verifica conformidade com Constituição
4. ✅ Analisa qualidade de código (testes, documentação, segurança)
5. ✅ Gera relatório estruturado: APPROVED ou REFUSED
6. ✅ Adiciona nota na task com resultado da revisão

**Saída**:
- 🟢 **APPROVED**: Todos os ACs atendidos + conformidade OK
- 🔴 **REFUSED**: ACs incompletos ou problemas detectados

**Quando usar**:
- SEMPRE antes de `/spec-retro`
- Quando task está em status "In Review"
- Para validar implementação de outro desenvolvedor

---

#### `/spec-retro` - Finalizar Task e Consolidar

**Objetivo**: Encerrar task com validação final e consolidação de conhecimento

**Uso**:
```bash
/spec-retro task-10
```

**O que faz**:
1. ✅ **Checklist obrigatório de 4 itens:**
   - Todos os ACs marcados como `[x]`
   - Task passou por `/spec-review` com APPROVED
   - Código commitado no Git
   - Testes passando
2. ✅ Atualiza task com resumo final estruturado em `notes`
3. ✅ Reporta progresso de milestone
4. ✅ Muda status para "Done"
5. ✅ Dispara consolidação no Basic Memory (background)

**Saída**:
- Task marcada como "Done"
- Resumo final adicionado (lições, decisões, commits)
- Progresso de milestone reportado (ex: 7/10 tasks = 70%)
- Conhecimento consolidado no Basic Memory

**Quando usar**:
- APENAS após `/spec-review` com APPROVED
- Quando TODOS os ACs estão concluídos
- Após commitar código e validar testes

---

### 🔄 Gerenciamento de Backlog

#### `/spec-replan` - Reestruturar Backlog

**Objetivo**: Adaptar backlog a mudanças críticas de cenário

**Uso**:
```bash
/spec-replan "Mudança de tecnologia: migrar de Express para Fastify"
```

**O que faz**:
1. ✅ Analisa impacto em tasks existentes
2. ✅ **Verifica impacto em dependências** (tasks que dependem de obsoletas)
3. ✅ **Verifica impacto em milestones** (% afetado de cada milestone)
4. ✅ Classifica tasks: Obsoletas, Mutantes, Lacunas
5. ✅ Arquiva tasks obsoletas (não deleta!)
6. ✅ Atualiza tasks mutantes com novos ACs/planos
7. ✅ Cria novas tasks para lacunas
8. ✅ Corrige dependências impactadas
9. ✅ Registra ADR sobre o replanejamento

**Saída**:
- Relatório de impacto (X obsoletas, Y mutantes, Z lacunas)
- Tasks arquivadas/atualizadas/criadas
- Dependências corrigidas
- Milestones impactados reportados
- ADR criada documentando mudança

**Quando usar**:
- Mudança de tecnologia/framework
- Pivot de arquitetura
- Novos requisitos de negócio incompatíveis com plano atual
- Após discovery que invalida premissas anteriores

---

#### `/spec-align` - Alinhar Constituição

**Objetivo**: Sincronizar documentação com realidade do código

**Uso**:
```bash
/spec-align
```

**O que faz**:
1. ✅ Lista TODOS os documentos de padrões via MCP
2. ✅ Lista decisões arquiteturais recentes
3. ✅ Analisa código real vs padrões documentados
4. ✅ Identifica divergências e padrões emergentes
5. ✅ **CRUD completo de documentos**:
   - **CREATE**: Novos documentos de padrões (`.backlog`)
   - **READ**: Ler Constituição e padrões
   - **UPDATE**: Atualizar Constituição via MCP
   - **DELETE**: Remover documentos obsoletos (raro)
6. ✅ Cria ADRs para decisões arquiteturais
7. ✅ Deprecia padrões obsoletos (sem deletar)
8. ✅ Sincroniza com Basic Memory

**Saída**:
- Documentos atualizados (ex: Constituição v1.0 → v1.1)
- Novos documentos criados (ex: padroes-seguranca.backlog)
- ADRs registradas
- Padrões deprecados marcados
- Basic Memory atualizado

**Quando usar**:
- Após concluir feature complexa com aprendizados
- Quando documentação está "descolada" do código
- Antes de iniciar épico grande
- Periodicamente (ex: trimestral)

---

#### `/spec-memorize` - Consolidar Conhecimento

**Objetivo**: Salvar aprendizados da sessão no Basic Memory

**Uso**:
```bash
/spec-memorize
```

**O que faz**:
1. ✅ Analisa contexto da sessão atual
2. ✅ Identifica candidatos à memória:
   - Erros & Soluções → `LessonLearned`
   - Decisões Técnicas → `ADR`
   - Padrões de Código → `Standard`
3. ✅ Propõe lista ao usuário para aprovação
4. ✅ Salva notas aprovadas no Basic Memory
5. ✅ Cria relações entre notas

**Saída**:
- Proposta de memorização apresentada
- Usuário aprova/edita itens
- Notas salvas no Basic Memory (Markdown)

**Quando usar**:
- Ao final de sessão produtiva
- Após resolver problema complexo
- Quando aprender algo não-óbvio
- Complementar ao `/spec-retro` (sessão vs task)

---

### 👀 Visualização e Busca

#### `/spec-board` - Quadro Kanban

**Objetivo**: Visualizar tasks organizadas por status

**Uso**:
```bash
/spec-board
# ou com filtros
/spec-board --milestone "v1.0 - MVP"
/spec-board --priority high --label backend
```

**O que faz**:
1. ✅ Executa `backlog board` (CLI)
2. ✅ Captura output e processa
3. ✅ Apresenta quadro formatado:
   - Colunas: To Do, In Progress, In Review, Done, Blocked
   - Tasks com prioridade, assignee, milestone, labels
4. ✅ Calcula estatísticas:
   - Total de tasks por status
   - Distribuição por prioridade
   - Progresso de milestones
   - Tasks bloqueadas

**Saída**:
- Quadro Kanban visual
- Estatísticas do backlog
- Tasks bloqueadas destacadas
- Ações sugeridas

**Quando usar**:
- Planejamento de sprint
- Daily standup
- Revisão semanal
- Identificação de gargalos

---

#### `/spec-search` - Busca Fuzzy

**Objetivo**: Buscar em tasks, specs, docs e ADRs

**Uso**:
```bash
/spec-search "autenticação"
# ou com filtros
/spec-search "bug" --status "To Do" --priority high
/spec-search "arquitetura" --type spec
/spec-search "framework" --type decision
```

**O que faz**:
1. ✅ Executa `backlog search` (CLI)
2. ✅ Busca fuzzy em TODOS os campos
3. ✅ Filtra por: status, priority, milestone, label, type
4. ✅ Ordena por relevância (score 0.0-1.0)
5. ✅ Agrupa resultados por tipo:
   - 📋 Tasks
   - 📄 Specs
   - 📖 Documentos de Padrões
   - 🎯 ADRs
6. ✅ Sugere ações com base nos resultados

**Saída**:
- Resultados agrupados por tipo
- Score de relevância para cada resultado
- Campos onde houve match
- Ações sugeridas

**Quando usar**:
- Encontrar task sem lembrar ID
- Revisar trabalho anterior sobre um tema
- Validar padrões antes de implementar
- Consultar ADRs relacionadas
- Auditoria de milestone
- Identificar duplicatas

---

## 🔧 Ferramentas MCP Disponíveis

### Tasks

```javascript
// Criar task
backlog_task_create({
  title, type, status, priority, labels, milestone,
  assignee, dependencies, acceptance_criteria, plan, notes
})

// Ler task
backlog_task_get("task-10")

// Listar tasks
backlog_task_list({ status: "To Do", priority: "high" })

// Atualizar task
backlog_task_update("task-10", { status: "In Progress", notes: "..." })

// Arquivar task
backlog_task_archive("task-10")
```

### Documentos

```javascript
// Criar documento (.backlog OBRIGATÓRIO)
backlog_doc_create({
  title, type: "spec" | "guide",
  path: "specs/SPEC-001-feature.backlog",  // ← .backlog!
  labels, content
})

// Ler documento
backlog_doc_get("doc-001")

// Listar documentos
backlog_doc_list({ path: "docs/standards/", type: "guide" })

// Atualizar documento
backlog_doc_update("doc-001", { content: "...", notes: "..." })

// Deletar documento (RARO)
backlog_doc_delete("doc-005")
```

### Decisões

```javascript
// Criar ADR
backlog_decision_create({
  title, context, decision, consequences, alternatives, status
})

// Listar ADRs
backlog_decision_list()

// Obter ADR específica
backlog_decision_get("ADR-007")
```

---

## 🎓 Fluxo de Trabalho Completo (Exemplo)

### Cenário: Implementar "Sistema de Autenticação JWT"

#### 1. Inicialização (Uma vez por projeto)

```bash
/spec-init
```

✅ Backlog MCP configurado
✅ Constituição criada

---

#### 2. Planejamento

```bash
/spec-plan "Sistema de Autenticação JWT"
```

✅ `task-10` criada com:
- Prioridade: high
- Milestone: v1.0 - MVP
- Labels: backend, security, api
- 4 Acceptance Criteria
- Plano de 7 etapas

✅ `SPEC-010-sistema-autenticacao.backlog` criada

---

#### 3. Execução

```bash
/spec-execute task-10
```

✅ Dependências verificadas (nenhuma)
✅ Spec lida e analisada
✅ Status: To Do → In Progress
✅ Subtarefas criadas:
- task-10-1: Endpoint /auth/login
- task-10-2: Middleware JWT
- task-10-3: Refresh token logic

✅ Implementação guiada por subagente
✅ Notas atualizadas progressivamente
✅ ACs marcados como `[x]` conforme implementa
✅ Status: In Progress → In Review

---

#### 4. Revisão

```bash
/spec-review task-10
```

🔍 Validação:
- ✅ TODOS os 4 ACs marcados como `[x]`
- ✅ Conformidade com Spec verificada
- ✅ Conformidade com Constituição OK
- ✅ Testes: 15 unitários, cobertura 92%
- ✅ Documentação: README atualizado

🟢 **APPROVED**

---

#### 5. Finalização

```bash
/spec-retro task-10
```

✅ Checklist validado:
- [x] ACs completos
- [x] Review APPROVED
- [x] Código commitado (3 commits)
- [x] Testes passando

✅ Resumo final adicionado em `notes`:
- Lições aprendidas: 2 itens
- Decisões técnicas: 3 itens
- Commits: `abc123`, `def456`, `ghi789`

✅ Milestone "v1.0 - MVP": 7/10 tasks (70%)

✅ Status: In Review → Done

✅ Memory MCP consolidando (background)

---

#### 6. Visualização

```bash
/spec-board --milestone "v1.0 - MVP"
```

📊 Quadro Kanban:
- To Do: 2 tasks
- In Progress: 1 task
- Done: 7 tasks (incluindo task-10!)

---

## ⚙️ Configuração

### Config.yml Padrão

```yaml
project_name: linderman-cc-utils
default_status: To Do
statuses:
  - To Do
  - In Progress
  - In Review
  - Done
  - Blocked
labels:
  - backend
  - frontend
  - plugin
  - skill
  - documentation
  - bugfix
  - enhancement
milestones:
  - "v1.0 - MVP"
  - "v2.0 - Full Integration"
date_format: yyyy-mm-dd HH:mm:ss
timezonePreference: America/Fortaleza
defaultEditor: code
autoCommit: false
bypassGitHooks: false
```

---

## 🚨 Regras Inegociáveis

1. **NUNCA** editar arquivos `.backlog` manualmente
2. **SEMPRE** usar ferramentas MCP para gerenciar tasks/docs
3. **OBRIGATÓRIO** extensão `.backlog` para specs e documentos de padrões
4. **PROIBIDO** aprovar task sem TODOS os ACs marcados como `[x]`
5. **OBRIGATÓRIO** passar por `/spec-review` antes de `/spec-retro`
6. **PROIBIDO** deletar tasks (arquivar via `backlog_task_archive`)
7. **OBRIGATÓRIO** consultar Constituição antes de implementar

---

## 📖 Recursos Adicionais

### CLI do Backlog

```bash
# Instalar
npm install -g backlog-md

# Comandos úteis
backlog board              # Kanban interativo
backlog browser            # Interface web
backlog task create        # Criar task via CLI
backlog doc create         # Criar documento via CLI
backlog decision create    # Criar ADR via CLI
backlog --help             # Ajuda completa
```

### Basic Memory

- Armazena lições aprendidas, ADRs, padrões em arquivos Markdown
- Busca via `search("termo")`
- Contexto carregado via `build_context()`

### Constituição

- Localização: `backlog/docs/standards/constituicao.backlog`
- Contém: Regras inegociáveis, padrões de código, arquitetura
- Atualização: Via `/spec-align`

---

## 🆘 Problemas Comuns

### "CLI backlog não encontrado"
```bash
# Solução:
npm install -g backlog-md
backlog --version
```

### "Task não pode ser finalizada (ACs incompletos)"
```bash
# Marcar ACs via CLI:
backlog task edit task-10 --check-ac "Login deve retornar JWT válido"

# Ou via MCP:
# Atualizar array acceptance_criteria com [x] em vez de [ ]
```

### "Spec com extensão .md foi rejeitada"
```bash
# Renomear para .backlog:
mv specs/SPEC-001-feature.md specs/SPEC-001-feature.backlog
```

### "Task bloqueada por dependências"
```bash
# Verificar dependências:
backlog task view task-10

# Resolver dependência primeiro:
/spec-execute task-5  # task que está bloqueando

# Depois:
/spec-execute task-10
```

---

## 📞 Suporte

- **Documentação MCP**: https://github.com/MrLesk/Backlog.md
- **Issues**: GitHub do projeto
- **Exemplos**: Consultar tasks existentes via `/spec-search`

---

## ✨ Novidades na v2.0

- ✅ Integração 100% com Backlog.md MCP
- ✅ Uso de TODOS os campos MCP (priority, labels, milestones, dependencies, etc.)
- ✅ Extensão `.backlog` obrigatória para specs e docs
- ✅ Validação automática de ACs em `/spec-review`
- ✅ Gerenciamento de dependências em `/spec-execute`
- ✅ Análise de impacto em milestones/dependências em `/spec-replan`
- ✅ CRUD completo de documentos em `/spec-align`
- ✅ Novos comandos: `/spec-board` e `/spec-search`
- ✅ Migração automática em `/spec-init`
- ✅ Progresso de milestones em `/spec-retro`
- ✅ Notas incrementais durante execução
