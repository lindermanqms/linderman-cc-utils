---
name: spec-search
description: Busca fuzzy em tasks, specs, documentos e decisões do backlog. Suporta filtros por status, prioridade, milestone, labels e type.
version: 1.0.0
category: workflow
triggers:
  - "/spec-search"
  - "buscar no backlog"
  - "procurar task"
  - "search"
  - "encontrar spec"
arguments:
  - name: query
    description: Termo de busca (pode ser texto livre, task-id, ou palavra-chave)
    required: true
---

# Spec-Search: Busca Inteligente no Backlog

Este comando realiza busca fuzzy em **TODOS** os artefatos do backlog: tasks, specs, documentos de padrões e decisões arquiteturais (ADRs). Suporta filtros avançados e busca semântica.

## Workflow de Busca

### Passo 1: Executar Busca via CLI

**Busca básica (termo livre):**

```bash
backlog search "autenticação"
```

**Busca com filtros:**

```bash
# Buscar apenas em tasks com status específico
backlog search "autenticação" --status "In Progress"

# Buscar por prioridade
backlog search "bug" --priority high

# Buscar em milestone específico
backlog search "API" --milestone "v1.0 - MVP"

# Buscar por labels
backlog search "segurança" --label backend

# Combinar múltiplos filtros
backlog search "refactor" --status "To Do" --priority medium --milestone "v2.0"

# Buscar apenas em specs
backlog search "arquitetura" --type spec

# Buscar apenas em documentos de padrões
backlog search "código" --type doc

# Buscar apenas em ADRs
backlog search "decisão" --type decision
```

### Passo 2: Capturar e Processar Resultados

**O comando retorna resultados estruturados:**

```javascript
// Executar busca via Bash
const searchResults = await execCommand(`backlog search "${query}" --format json ${filters}`)

// Processar JSON retornado
const results = JSON.parse(searchResults)

/*
Estrutura do JSON:
{
  "query": "autenticação",
  "filters": { "status": "In Progress", "priority": "high" },
  "totalResults": 8,
  "results": [
    {
      "type": "task",
      "id": "task-10",
      "title": "Sistema de Autenticação JWT",
      "status": "In Progress",
      "priority": "high",
      "milestone": "v1.0 - MVP",
      "labels": ["backend", "security", "api"],
      "score": 0.95,  // Relevância da busca
      "matchedFields": ["title", "description", "labels"]
    },
    {
      "type": "spec",
      "id": "SPEC-003",
      "title": "SPEC-003: Sistema de Autenticação",
      "path": "specs/SPEC-003-sistema-autenticacao.backlog",
      "score": 0.87,
      "matchedFields": ["title", "content"]
    },
    {
      "type": "doc",
      "id": "doc-005",
      "title": "Padrões de Segurança",
      "path": "docs/standards/padroes-seguranca.backlog",
      "score": 0.72,
      "matchedFields": ["content"]
    },
    {
      "type": "decision",
      "id": "ADR-007",
      "title": "ADR-007: Escolha de JWT vs Sessões",
      "status": "accepted",
      "score": 0.68,
      "matchedFields": ["title", "decision"]
    }
  ]
}
*/
```

### Passo 3: Apresentar Resultados Formatados

**Apresentar ao usuário de forma estruturada:**

```javascript
console.log(`🔍 **Resultados para "${results.query}"**`)
console.log("")

if (results.totalResults === 0) {
  console.log("   Nenhum resultado encontrado.")
  console.log("")
  console.log("   💡 Dicas:")
  console.log("   - Tente termos mais gerais")
  console.log("   - Remova filtros para ampliar busca")
  console.log("   - Verifique ortografia")
  return
}

console.log(`   Total: ${results.totalResults} resultados`)
console.log("")

// Agrupar por tipo
const grouped = {
  task: results.results.filter(r => r.type === "task"),
  spec: results.results.filter(r => r.type === "spec"),
  doc: results.results.filter(r => r.type === "doc"),
  decision: results.results.filter(r => r.type === "decision")
}

// Tasks
if (grouped.task.length > 0) {
  console.log("## 📋 Tasks")
  console.log("")
  grouped.task.forEach(task => {
    const priorityEmoji = {
      critical: "🔴",
      high: "🟠",
      medium: "🟡",
      low: "🟢"
    }[task.priority]

    console.log(`   ${priorityEmoji} **${task.id}**: ${task.title}`)
    console.log(`      Status: ${task.status} | Prioridade: ${task.priority.toUpperCase()}`)
    if (task.milestone) {
      console.log(`      Milestone: ${task.milestone}`)
    }
    if (task.labels.length > 0) {
      console.log(`      Labels: ${task.labels.join(", ")}`)
    }
    console.log(`      Relevância: ${(task.score * 100).toFixed(0)}%`)
    console.log(`      Campos encontrados: ${task.matchedFields.join(", ")}`)
    console.log("")
  })
}

// Specs
if (grouped.spec.length > 0) {
  console.log("## 📄 Specs")
  console.log("")
  grouped.spec.forEach(spec => {
    console.log(`   📄 **${spec.id}**: ${spec.title}`)
    console.log(`      Path: ${spec.path}`)
    console.log(`      Relevância: ${(spec.score * 100).toFixed(0)}%`)
    console.log(`      Campos encontrados: ${spec.matchedFields.join(", ")}`)
    console.log("")
  })
}

// Documentos de Padrões
if (grouped.doc.length > 0) {
  console.log("## 📖 Documentos de Padrões")
  console.log("")
  grouped.doc.forEach(doc => {
    console.log(`   📖 **${doc.id}**: ${doc.title}`)
    console.log(`      Path: ${doc.path}`)
    console.log(`      Relevância: ${(doc.score * 100).toFixed(0)}%`)
    console.log(`      Campos encontrados: ${doc.matchedFields.join(", ")}`)
    console.log("")
  })
}

// ADRs
if (grouped.decision.length > 0) {
  console.log("## 🎯 Decisões Arquiteturais (ADRs)")
  console.log("")
  grouped.decision.forEach(adr => {
    const statusEmoji = {
      proposed: "📝",
      accepted: "✅",
      rejected: "❌",
      deprecated: "⚠️"
    }[adr.status]

    console.log(`   ${statusEmoji} **${adr.id}**: ${adr.title}`)
    console.log(`      Status: ${adr.status}`)
    console.log(`      Relevância: ${(adr.score * 100).toFixed(0)}%`)
    console.log(`      Campos encontrados: ${adr.matchedFields.join(", ")}`)
    console.log("")
  })
}
```

### Passo 4: Ações Sugeridas (Opcional)

**Com base nos resultados, sugerir próximos passos:**

```javascript
console.log("---")
console.log("")
console.log("## 🎯 Ações Sugeridas")
console.log("")

// Se encontrou tasks
if (grouped.task.length > 0) {
  const highPriorityTasks = grouped.task.filter(t => t.priority === "high" || t.priority === "critical")
  if (highPriorityTasks.length > 0) {
    console.log(`   - ${highPriorityTasks.length} task(s) de alta prioridade encontrada(s)`)
    console.log(`     Considere executar: /spec-execute ${highPriorityTasks[0].id}`)
  }

  const inProgressTasks = grouped.task.filter(t => t.status === "In Progress")
  if (inProgressTasks.length > 0) {
    console.log(`   - ${inProgressTasks.length} task(s) em progresso encontrada(s)`)
    console.log(`     Verifique status: backlog task view ${inProgressTasks[0].id}`)
  }
}

// Se encontrou specs
if (grouped.spec.length > 0) {
  console.log(`   - ${grouped.spec.length} spec(s) relacionada(s) encontrada(s)`)
  console.log(`     Leia a spec: backlog doc get ${grouped.spec[0].id}`)
}

// Se encontrou ADRs
if (grouped.decision.length > 0) {
  console.log(`   - ${grouped.decision.length} ADR(s) relevante(s) encontrada(s)`)
  console.log(`     Consulte decisão: backlog decision get ${grouped.decision[0].id}`)
}
```

## Tipos de Busca Suportados

### 1. Busca por Texto Livre

```bash
/spec-search "autenticação JWT"
```

Busca o termo em todos os campos: título, descrição, content, notas, ACs, etc.

### 2. Busca por ID Exato

```bash
/spec-search "task-10"
```

Retorna a task específica task-10.

### 3. Busca com Filtros de Status

```bash
/spec-search "bug" --status "To Do"
```

Filtra resultados por status: To Do, In Progress, In Review, Done, Blocked.

### 4. Busca com Filtros de Prioridade

```bash
/spec-search "feature" --priority high
```

Filtra resultados por prioridade: critical, high, medium, low.

### 5. Busca com Filtros de Milestone

```bash
/spec-search "API" --milestone "v1.0 - MVP"
```

Retorna apenas resultados do milestone especificado.

### 6. Busca com Filtros de Label

```bash
/spec-search "refactor" --label backend
```

Retorna apenas resultados com o label especificado.

### 7. Busca por Tipo de Artefato

```bash
# Apenas tasks
/spec-search "auth" --type task

# Apenas specs
/spec-search "arquitetura" --type spec

# Apenas documentos de padrões
/spec-search "código" --type doc

# Apenas ADRs
/spec-search "framework" --type decision
```

## Algoritmo de Relevância

O CLI `backlog search` usa busca fuzzy com pontuação de relevância:

- **Score 0.9-1.0**: Match exato no título ou ID
- **Score 0.7-0.9**: Match no título ou descrição
- **Score 0.5-0.7**: Match em content, notas ou ACs
- **Score 0.3-0.5**: Match em labels ou metadata
- **Score <0.3**: Match fraco (pode ser ruído)

Resultados são ordenados por relevância (score descendente).

## Saída Esperada Completa

```markdown
🔍 **Resultados para "autenticação"**

   Total: 8 resultados

## 📋 Tasks

   🟠 **task-10**: Sistema de Autenticação JWT
      Status: In Progress | Prioridade: HIGH
      Milestone: v1.0 - MVP
      Labels: backend, security, api
      Relevância: 95%
      Campos encontrados: title, description, labels

   🟡 **task-3**: Refatoração do Módulo de Autenticação
      Status: In Review | Prioridade: MEDIUM
      Milestone: v1.0 - MVP
      Labels: backend, refactor
      Relevância: 82%
      Campos encontrados: title, notes

   🟢 **task-15**: Documentar Fluxo de Autenticação
      Status: To Do | Prioridade: LOW
      Milestone: v2.0
      Labels: documentation
      Relevância: 68%
      Campos encontrados: title

## 📄 Specs

   📄 **SPEC-003**: SPEC-003: Sistema de Autenticação
      Path: specs/SPEC-003-sistema-autenticacao.backlog
      Relevância: 87%
      Campos encontrados: title, content

## 📖 Documentos de Padrões

   📖 **doc-005**: Padrões de Segurança
      Path: docs/standards/padroes-seguranca.backlog
      Relevância: 72%
      Campos encontrados: content

   📖 **doc-001**: Constituição do Projeto
      Path: docs/standards/constituicao.backlog
      Relevância: 45%
      Campos encontrados: content

## 🎯 Decisões Arquiteturais (ADRs)

   ✅ **ADR-007**: ADR-007: Escolha de JWT vs Sessões
      Status: accepted
      Relevância: 68%
      Campos encontrados: title, decision

   📝 **ADR-012**: ADR-012: Integração com OAuth2
      Status: proposed
      Relevância: 53%
      Campos encontrados: context, alternatives

---

## 🎯 Ações Sugeridas

   - 2 task(s) de alta prioridade encontrada(s)
     Considere executar: /spec-execute task-10
   - 1 task(s) em progresso encontrada(s)
     Verifique status: backlog task view task-10
   - 1 spec(s) relacionada(s) encontrada(s)
     Leia a spec: backlog doc get SPEC-003
   - 2 ADR(s) relevante(s) encontrada(s)
     Consulte decisão: backlog decision get ADR-007
```

## Casos de Uso

### 1. Encontrar Tasks Relacionadas

```bash
/spec-search "Redis" --type task
```

Retorna todas as tasks que mencionam Redis.

### 2. Verificar Padrões Existentes

```bash
/spec-search "nomenclatura" --type doc
```

Busca documentos de padrões que falam sobre nomenclatura.

### 3. Revisar Decisões Arquiteturais

```bash
/spec-search "framework" --type decision
```

Lista ADRs relacionadas a escolha de frameworks.

### 4. Identificar Tasks Bloqueadas

```bash
/spec-search "bug" --status Blocked
```

Encontra bugs que estão bloqueados.

### 5. Priorizar Trabalho

```bash
/spec-search "" --status "To Do" --priority critical
```

Lista tasks críticas pendentes (busca vazia com filtros).

### 6. Auditoria de Milestone

```bash
/spec-search "" --milestone "v1.0 - MVP"
```

Lista TUDO relacionado ao milestone v1.0.

## Busca via MCP (Alternativa à CLI)

### Busca em Documentos via MCP

**O MCP `document_search` oferece busca fuzzy especializada em documentos:**

```javascript
// Buscar specs contendo "autenticação"
const docResults = await backlog_document_search({
  query: "autenticação",
  type: "spec"  // Opcional: spec, guide, standard
})

// Resultado:
// [
//   { id: "SPEC-003", title: "...", path: "specs/SPEC-003...", score: 0.95 },
//   { id: "SPEC-015", title: "...", path: "specs/SPEC-015...", score: 0.72 }
// ]
```

**Comparativo: CLI vs MCP**

| Funcionalidade | CLI `backlog search` | MCP `document_search` |
|--------------|----------------------|----------------------|
| **Alcance** | Tasks + Docs + ADRs | Apenas Documentos |
| **Busca** | Fuzzy (terminal) | Fuzzy (MCP) |
| **Filtros** | Status, priority, etc. | Type (spec, guide, standard) |
| **Output** | JSON ou texto | JSON estruturado |
| **Performance** | Índice global | Índice de documentos |
| **Uso ideal** | Busca geral | Busca específica de docs |

**Quando usar `document_search`:**
- ✅ Busca específica em specs, guias ou padrões
- ✅ Integração com comandos como `/spec-align` e `/spec-plan`
- ✅ Validação de duplicação antes de criar novo padrão
- ✅ Exploração de documentação técnica

### Exemplo de Integração com `/spec-align`

```javascript
// Antes de criar novo padrão, verificar se já existe
const existing = await backlog_document_search({
  query: "padrões de código",
  type: "standard"
})

if (existing.length > 0) {
  console.log(`⚠️ Padrão já existe: ${existing[0].id}`)
  console.log(`   Path: ${existing[0].path}`)
  console.log("\nDeseja:")
  console.log("1. Ver o padrão existente")
  console.log("2. Criar um novo mesmo assim")
  console.log("3. Atualizar o existente")

  // Aguardar decisão do usuário
} else {
  // Prosseguir com criação
  await backlog_doc_create({
    title: "Padrões de Código",
    type: "standard",
    content: "..."
  })
}
```

## Integração com Basic Memory (Opcional)

**Após busca, salvar consultas frequentes como notas de busca rápida:**

```javascript
// Se o usuário busca frequentemente pelo mesmo termo
if (queryCount > 3) {
  write_note({
    title: `[SearchPattern] - ${query}`,
    content: `---
type: Pattern
tags: [search, automation]
project: linderman-cc-utils
---
# Busca Frequente: ${query}

## Detalhes
- Query: ${query}
- Filtros comuns: ${JSON.stringify(filters)}
- Frequência: ${queryCount} vezes
- Última busca: ${timestamp}
`
  })
}
```

## Quando Usar?

- **Encontrar task específica** sem lembrar o ID exato
- **Revisar trabalho anterior** sobre um tema (ex: todas as tasks de autenticação)
- **Validar padrões** antes de implementar feature similar
- **Consultar ADRs** relacionadas a uma decisão técnica
- **Auditoria de milestone** para verificar progresso
- **Identificar duplicatas** antes de criar nova task
- **Onboarding** para encontrar documentação relevante rapidamente

## Notas Importantes

- **CLI Obrigatório**: Requer CLI `backlog` instalado e acessível
- **Busca Fuzzy**: Aceita typos e variações (ex: "autenticacao\" encontra \"autenticação\")
- **Case Insensitive**: Não diferencia maiúsculas/minúsculas
- **Campos Buscados**: Título, descrição, content, notas, ACs, labels, milestone
- **Score de Relevância**: Resultados ordenados por relevância (0.0-1.0)
- **Filtros Múltiplos**: Combinar filtros estreita resultados (AND lógico)
- **Busca Vazia com Filtros**: `\"\"` como query + filtros = listar com filtros
- **Performance**: Busca indexada é rápida mesmo com centenas de tasks
- **JSON Output**: Flag `--format json` permite processamento programático
- **Integração com Workflow**: Usar após `/spec-plan` para verificar se feature similar já existe
- **Salvando Padrões**: Consultas frequentes podem ser salvas no Basic Memory para consulta futura
