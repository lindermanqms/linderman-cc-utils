# Integração Gemini + Backlog.md

Guia completo para integração entre agentes Gemini e o servidor MCP Backlog.md, incluindo atualização obrigatória de status e ACs.

## 🎯 Visão Geral

**Regra Obrigatória**: Quando agentes Gemini assumem tasks em projetos que usam spec-workflow com Backlog.md, eles DEVEM atualizar o backlog automaticamente.

**Por que essa regra existe:**
- ✅ **Rastreio**: Sabe-se que Gemini está trabalhando na task
- ✅ **Transparência**: Progresso visível no backlog
- ✅ **Comunicação**: Claude Code sabe o status atual
- ✅ **Não duplicidade**: Evita atualizações manuais

## 📋 Quando Aplicar

**⚠️ CONDICIONAL**: Aplica-se APENAS quando:
1. Projeto usa **spec-workflow** plugin
2. Projeto tem **Backlog.md MCP** integrado
3. Task está sendo gerenciada via **backlog_task_create/update**

## 🔄 Ciclo de Vida da Task com Gemini

### 1. AO ASSUMIR A TASK (Início - OBRIGATÓRIO)

**Agente Gemini DEVE executar IMEDIATAMENTE:**

```javascript
// Obter task
const task = backlog_task_get(taskId)

// Atualizar status para "In Progress"
backlog_task_update(taskId, {
  status: "In Progress",
  notes: task.notes + `\n\n## 🤖 Assumida por Gemini-3-Flash\nData: ${new Date().toISOString()}\nVia: gemini-orchestrator\n`
})

// Informar
console.log("✅ Task ${taskId} assumida por Gemini-3-Flash")
console.log("📋 Backlog atualizado: Status → In Progress")
```

**Exemplo de output esperado:**
```
✅ Task task-10 assumida por Gemini-3-Flash
📋 Backlog atualizado: Status → In Progress

Iniciando implementação...
```

### 2. DURANTE IMPLEMENTAÇÃO (Opcional)

**Agentes Gemini PODEM atualizar progresso:**

```javascript
// Após cada milestone significativo
backlog_task_update(taskId, {
  notes: task.notes + `\n\n### Progresso (${timestamp})\n- ✅ ${milestone1}\n- ✅ ${milestone2}\n`
})
```

**Exemplos de milestones:**
- Configuração de ambiente concluída
- Models criados
- Services implementados
- Testes unitários passando

### 3. AO CONCLUIR A TASK (Fim - OBRIGATÓRIO)

**Agente Gemini DEVE executar ANTES de finalizar:**

```javascript
// 1. Marcar TODOS os ACs como concluídos
backlog_task_edit(taskId, {
  check_acceptance_criteria: [1, 2, 3, 4, 5]  // Todos os índices
})

// 2. Atualizar status para "Done"
backlog_task_update(taskId, {
  status: "Done",
  notes: task.notes + `\n\n## ✅ Concluída por Gemini-3-Flash\nData: ${new Date().toISOString()}\n\n### Acceptance Criteria\nTodos os ACs marcados como [x]:\n${task.acceptance_criteria.map(ac => '- ' + ac).join('\n')}\n\n### Relatório\nImplementação completa. Backlog atualizado.\n`
})

// 3. Informar OBRIGATORIAMENTE
console.log("✅ Task ${taskId} concluída com sucesso!")
console.log("📋 Backlog atualizado:")
console.log("   - Status: Done")
console.log("   - ACs: " + task.acceptance_criteria.length + "/" + task.acceptance_criteria.length + " completos")
console.log("   - Notes: Progresso registrado")
```

**Exemplo de output esperado:**
```
✅ Task task-10 concluída com sucesso!
📋 Backlog atualizado:
   - Status: Done
   - ACs: 5/5 completos
   - Notes: Progresso registrado

Implementação finalizada.
```

## 🔧 Implementação no Prompt do Gemini

### Template para Flash Implementation

**Adicionar esta seção ao prompt enviado ao Gemini:**

```markdown
## 📋 GESTÃO DE BACKLOG (OBRIGATÓRIO)

Este projeto usa spec-workflow com Backlog.md MCP.

### AO ASSUMIR A TASK:
1. Execute: `backlog_task_update("${TASK_ID}", { status: "In Progress", notes: task.notes + "\\n\\n## 🤖 Assumida por Gemini-3-Flash\\n" + timestamp })`
2. Informe: "✅ Task assumida. Backlog atualizado."

### AO CONCLUIR A TASK:
1. Execute: `backlog_task_edit("${TASK_ID}", { check_acceptance_criteria: [1,2,3,4,5] })`
2. Execute: `backlog_task_update("${TASK_ID}", { status: "Done", notes: ... })`
3. Informe: "✅ Task concluída. Backlog atualizado."

### NÃO ESQUEÇA:
- ATUALIZAR o backlog ao assumir
- ATUALIZAR o backlog ao concluir
- MARCAR todos os ACs como [x]
- INFORMAR sempre que atualizou
```

### Exemplo Completo de Prompt

```markdown
# Task: Implementar Sistema de Autenticação

## 📋 GESTÃO DE BACKLOG (OBRIGATÓRIO)

Task ID: task-10

### AO ASSUMIR:
```javascript
backlog_task_update("task-10", {
  status: "In Progress",
  notes: task.notes + "\n\n## 🤖 Assumida por Gemini-3-Flash\n2026-01-13T10:30:00Z\n"
})
```

### AO CONCLUIR:
```javascript
backlog_task_edit("task-10", {
  check_acceptance_criteria: [1,2,3,4,5]
})
backlog_task_update("task-10", {
  status: "Done",
  notes: task.notes + "\n\n## ✅ Concluída por Gemini-3-Flash\n2026-01-13T12:45:00Z\nACs: 5/5 completos\n"
})
```

## Requisitos

Veja abaixo os requisitos detalhados...
```

## 🚨 Verificação e Cobrança

### Se Gemini NÃO atualizou ao assumir:

**Claude Code DEVE cobrar:**

```javascript
"⚠️ Gemini assumiu a task mas NÃO atualizou o backlog!

   Por favor, execute:
   backlog_task_update('task-10', {
     status: 'In Progress',
     notes: task.notes + '\\n\\n## 🤖 Assumida por Gemini-3-Flash\\n' + timestamp
   })"
```

### Se Gemini NÃO atualizou ao concluir:

**Claude Code DEVE cobrar:**

```javascript
"⚠️ Gemini concluiu a task mas NÃO atualizou o backlog!

   Por favor, execute:
   1. backlog_task_edit('task-10', { check_acceptance_criteria: [1,2,3,4,5] })
   2. backlog_task_update('task-10', { status: 'Done', notes: ... })
"
```

## ✅ Checklist de Validação

### Para Claude Code (Orchestrator):

**Após Gemini concluir, VERIFICAR:**

- [ ] Status da task está "Done"
- [ ] Todos os ACs estão marcados como [x]
- [ ] Notes contém "Concluída por Gemini-3-Flash"
- [ ] Gemini informou "Backlog atualizado"

**SE faltar qualquer item:**
- Cobrar agente Gemini
- Atualizar manualmente se necessário
- Documentar na task que a atualização foi manual

## 📊 Exemplos Práticos

### Exemplo 1: Task Simples

**Task**: "Criar botão de login"

**Gemini executa:**

```javascript
// 1. Ao assumir
backlog_task_update("task-20", {
  status: "In Progress",
  notes: "... ## 🤖 Assumida por Gemini-3-Flash\n2026-01-13 10:00\n"
})

// 2. Implementa botão

// 3. Ao concluir
backlog_task_edit("task-20", { check_acceptance_criteria: [1,2] })
backlog_task_update("task-20", {
  status: "Done",
  notes: "... ## ✅ Concluída por Gemini-3-Flash\n2026-01-13 10:30\nACs: 2/2 completos\n"
})
```

### Exemplo 2: Task Complexa com Subtasks

**Main Task**: "Sistema de Autenticação"
**Subtasks**: task-21, task-22, task-23

**Gemini executa para cada subtask:**

```javascript
// Subtask 1: Models
backlog_task_update("task-21", { status: "In Progress" })
// ... implement ...
backlog_task_edit("task-21", { check_acceptance_criteria: [1,2,3] })
backlog_task_update("task-21", { status: "Done" })

// Subtask 2: Services
backlog_task_update("task-22", { status: "In Progress" })
// ... implement ...
backlog_task_edit("task-22", { check_acceptance_criteria: [1,2] })
backlog_task_update("task-22", { status: "Done" })

// Subtask 3: API
backlog_task_update("task-23", { status: "In Progress" })
// ... implement ...
backlog_task_edit("task-23", { check_acceptance_criteria: [1,2,3,4] })
backlog_task_update("task-23", { status: "Done" })
```

## 🔍 Troubleshooting

### Problema: Gemini não atualiza backlog

**Sintoma**: Task concluída mas status continua "In Progress"

**Causa**: Gemini esqueceu de executar atualização

**Solução**:
1. Cobrar Gemini: "⚠️ Backlog não atualizado! Execute os comandos acima."
2. Se Gemini não responder: Atualizar manualmente
3. Documentar: "Atualização manual por Claude Code"

### Problema: ACs não marcados como [x]

**Sintoma**: Status "Done" mas ACs ainda [ ]

**Causa**: Gemini executou `update` mas esqueceu `edit` para ACs

**Solução**:
1. Executar `backlog_task_edit(taskId, { check_acceptance_criteria: [...] })`
2. Verificar se todos os ACs foram implementados
3. Documentar no notes

### Problema: Gemini informa que atualizou mas não atualizou

**Sintoma**: Output diz "Backlog atualizado" mas status não mudou

**Causa**: Erro na execução do comando MCP

**Solução**:
1. Verificar logs do Gemini
2. Executar comandos manualmente
3. Investigar se servidor MCP está respondendo

## 📚 Referências Relacionadas

- **spec-workflow**: `/spec-execute` - Execução de tasks com validação
- **gemini-orchestrator**: SKILL.md - Workflow de orquestração
- **acceptance-criteria-management.md** - Gerenciamento de ACs

## 🎯 Benefícios

- ✅ **Rastreio completo**: Saber sempre quem está fazendo o quê
- ✅ **Transparência**: Status sempre atualizado
- ✅ **Não duplicidade**: Gemini atualiza, não Claude Code
- ✅ **Auditoria**: Histórico completo no notes
- ✅ **Comunicação**: Claude Code sabe status sem consultar Gemini

## ⚠️ Regras de Ouro

1. **AO ASSUMIR**: Sempre atualizar status → "In Progress"
2. **AO CONCLUIR**: Sempre marcar ACs + status → "Done"
3. **SEMPRE informar**: "Backlog atualizado"
4. **NUNCA esquecer**: Atualização é OBRIGATÓRIA
5. **SE falhar**: Cobrar e atualizar manualmente
