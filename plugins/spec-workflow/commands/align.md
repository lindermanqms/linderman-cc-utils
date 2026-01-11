---
name: spec-align
description: Sessão de alinhamento estratégico para discutir e atualizar a "Constituição" do projeto com base na realidade do código. Gerencia documentos de padrões via MCP.
version: 2.0.0
category: workflow
triggers:
  - "/spec-align"
  - "alinhamento estratégico"
  - "revisar padrões"
  - "discutir arquitetura"
  - "atualizar constituição"
---

# Spec-Align: Alinhamento Estratégico e Evolução de Padrões

O `/spec-align` é um espaço para reflexão sobre os rumos do projeto e a eficácia dos padrões estabelecidos (A Constituição). Este comando gerencia TODOS os documentos de padrões via **Backlog.md MCP**, usando exclusivamente a extensão `.backlog`.

## Workflow de Alinhamento (OBRIGATÓRIO)

### Fase 1: Panorama Atual - Listar Padrões Existentes

**1. Listar TODOS os documentos de standards via MCP:**

```javascript
// Buscar documentos em docs/standards/
const standards = backlog_doc_list({ path: "docs/standards/" })

console.log("📚 Documentos de Padrões Atuais:")
standards.forEach(doc => {
  console.log(`   - ${doc.id}: ${doc.title}`)
  console.log(`     Path: ${doc.path}`)
  console.log(`     Labels: ${doc.labels.join(", ")}`)
})
```

**2. Listar decisões arquiteturais recentes:**

```javascript
const decisions = backlog_decision_list()

console.log("\n🎯 Decisões Arquiteturais Recentes:")
decisions.slice(0, 5).forEach(adr => {
  console.log(`   - ${adr.id}: ${adr.title}`)
  console.log(`     Status: ${adr.status}`)
  console.log(`     Data: ${adr.creation_date}`)
})
```

**3. Ler Constituição completa:**

```javascript
// Documento principal de padrões
const constituicao = backlog_doc_get("doc-001")  // ou buscar por path

console.log("\n🏛️ Constituição Atual:")
console.log(`   Versão: ${constituicao.metadata.version}`)
console.log(`   Última atualização: ${constituicao.metadata.update_date}`)
console.log(`   Labels: ${constituicao.labels.join(", ")}`)
```

### Fase 2: Reality Check - Análise do Código Real

**Comparar padrões documentados com código existente:**

```javascript
// 1. Analisar código relevante do projeto
// 2. Identificar divergências entre documentação e prática
// 3. Identificar padrões emergentes não documentados

const divergencias = []
const padrõesEmergentes = []

// Exemplo de verificação:
// - Estrutura de arquivos segue o padrão?
// - Nomenclatura está consistente?
// - Novas tecnologias não documentadas?
// - Padrões deprecados ainda em uso?
```

**Provocações ao usuário:**

```markdown
⚠️ **Divergências Identificadas:**

1. **Estrutura de Diretórios:**
   - Padrão documentado: `src/modules/[nome]/`
   - Encontrado no código: `src/components/[nome]/`
   - Questão: Devemos atualizar a Constituição ou refatorar o código?

2. **Tecnologia Nova Detectada:**
   - Uso de [Tecnologia X] em [módulo Y]
   - Não há registro na Constituição ou ADRs
   - Questão: Foi uma decisão consciente? Devemos formalizar?

3. **Padrão Obsoleto:**
   - Constituição define uso de [Pattern X]
   - Código recente usa [Pattern Y]
   - Questão: [Pattern X] deve ser depreciado?
```

### Fase 3: Discussão e Propostas

**Apresentar opções ao usuário:**

Para cada divergência/padrão emergente, propor ações:

1. **Atualizar Constituição** (aceitar novo padrão)
2. **Corrigir código** (forçar conformidade)
3. **Criar nova ADR** (documentar decisão)
4. **Depreciar padrão antigo** (marcar como obsoleto)
5. **Criar novo documento de padrão** (especialização)

### Fase 4: Execução das Mudanças via MCP

#### 4.1 Atualizar Documento Existente

**Para atualizar a Constituição ou outro documento de padrão:**

```javascript
// Ler documento atual
const doc = backlog_doc_get("doc-001")

// Preparar novo conteúdo
const novoConteudo = `---
id: doc-001
title: Constituição do Projeto
type: guide
labels: [standards, architecture]
version: ${incrementVersion(doc.metadata.version)}
update_date: ${timestamp}
---

# Constituição do Projeto: linderman-cc-utils

## Regras Inegociáveis

1. **Spec-First**: Toda feature DEVE ter uma Spec antes de implementação
2. **AC Obrigatório**: Toda task DEVE ter Acceptance Criteria verificáveis
... (conteúdo existente)

## ✨ NOVO: Estrutura de Diretórios (Atualizado em ${timestamp})

**Padrão Adotado:**
\`\`\`
src/
  components/  # ← NOVO: Antes era modules/
    [nome]/
      index.ts
      [nome].test.ts
\`\`\`

**Motivo da mudança:** Alinhamento com convenções do framework React.

... (resto do conteúdo)
`

// Atualizar via MCP
backlog_doc_update("doc-001", {
  content: novoConteudo
})

console.log("✅ Constituição atualizada!")
```

#### 4.2 Criar Novo Documento de Padrão

**Para especializar padrões (ex: criar "Padrões de Segurança" separado):**

```javascript
backlog_doc_create({
  title: "Padrões de Segurança",
  type: "guide",
  path: "docs/standards/padroes-seguranca.backlog",  // ← EXTENSÃO .backlog OBRIGATÓRIA
  labels: ["standards", "security"],
  content: `---
id: doc-{{auto-increment}}
title: Padrões de Segurança
type: guide
labels: [standards, security]
version: 1.0
creation_date: ${timestamp}
---

# Padrões de Segurança

## Autenticação

1. **JWT obrigatório** para APIs
2. **Refresh tokens** com rotação automática
3. **Rate limiting** configurado

## Validação de Input

1. **Nunca** confiar em dados do cliente
2. **Sanitizar** todos os inputs
3. **Validar** tipos e formatos

## Secrets Management

1. **NUNCA** commitar secrets no Git
2. **Usar** variáveis de ambiente
3. **Rotacionar** secrets a cada 90 dias

## Referências

- OWASP Top 10: https://owasp.org/
- ADR-007: Escolha de JWT vs Sessões
  `
})

console.log("✅ Novo documento de padrão criado: padroes-seguranca.backlog")
```

**IMPORTANTE: Validação de extensão:**

```javascript
// Rejeitar tentativas de criar documentos com extensão .md
if (path.endsWith('.md')) {
  throw new Error('❌ Extensão .md não permitida para documentos de padrões! Use .backlog obrigatoriamente.')
}
```

#### 4.3 Criar ADR (Architecture Decision Record)

**Para documentar decisões arquiteturais importantes:**

```javascript
backlog_decision_create({
  title: "ADR-008: Migração de modules/ para components/",
  context: `
Durante o desenvolvimento, percebemos que a estrutura modules/ não se alinhava
com as convenções do framework React. A comunidade usa components/ como padrão.
  `,
  decision: `
Adotamos a estrutura components/ para organizar nosso código frontend,
migrando todo código existente de modules/ para components/.
  `,
  consequences: `
**Positivas:**
- Melhor alinhamento com convenções React
- Facilita onboarding de novos desenvolvedores
- Compatibilidade com ferramentas da comunidade

**Negativas:**
- Requer refatoração de imports em ~50 arquivos
- Quebra de compatibilidade com código antigo (se houver)
  `,
  alternatives: `
1. Manter modules/ e criar alias para components/ → Rejeitado (duplicação)
2. Usar lib/ como alternativa → Rejeitado (ambíguo)
  `,
  status: "accepted"
})

console.log("✅ ADR-008 criada e registrada!")
```

#### 4.4 Depreciar Padrão Antigo

**Para marcar padrões como obsoletos:**

```javascript
// Atualizar Constituição marcando padrão como deprecado
const doc = backlog_doc_get("doc-001")

const conteudoAtualizado = doc.content.replace(
  /## Estrutura de Diretórios/,
  `## Estrutura de Diretórios

⚠️ **DEPRECADO (${timestamp})**: O padrão \`modules/\` foi substituído por \`components/\`.
Ver ADR-008 para detalhes.

---

## Estrutura de Diretórios (ATUAL)`
)

backlog_doc_update("doc-001", {
  content: conteudoAtualizado,
  notes: doc.notes + `\n\n## 🔄 Depreciação (${timestamp})\n` +
         `Padrão modules/ marcado como deprecado. Substituído por components/.`
})
```

#### 4.5 Deletar Documento (RARO)

**Apenas se o documento estiver completamente obsoleto e sem referências:**

```javascript
// ⚠️ CUIDADO: Operação destrutiva!
// Verificar antes se não há referências em tasks, specs ou outros docs

const docId = "doc-005"
const referencias = // Buscar tasks/specs que mencionam este doc

if (referencias.length > 0) {
  console.error(`❌ Não é possível deletar ${docId}: ${referencias.length} referências encontradas`)
} else {
  backlog_doc_delete(docId)
  console.log(`✅ Documento ${docId} removido`)
}
```

### Fase 5: Sincronização com Basic Memory

**Após atualizar padrões, salvar no Basic Memory para consulta futura:**

```javascript
// Criar ou atualizar nota de Standard
write_note({
  title: "[Standard] - Estrutura de Diretórios",
  content: `---
type: Standard
tags: [architecture, standards]
project: linderman-cc-utils
---
# Padrão: Estrutura de Diretórios

- Padrão atual: components/ (migrado de modules/)
- Decisão: ADR-008
- Data de adoção: ${timestamp}
- Motivo: Alinhamento com convenções React
`,
  relations: [
    { to: "ADR-008", label: "based_on" }
  ]
})
```

### Fase 6: Comunicação ao Usuário

**Relatório final estruturado:**

```markdown
⚖️ **Sessão de Alinhamento Estratégico Concluída**

**📊 Análise Realizada:**
- Documentos de padrões revisados: {{N documentos}}
- Divergências identificadas: {{N divergências}}
- Padrões emergentes detectados: {{N padrões}}

---

## 🔄 Mudanças Aplicadas

### Documentos Atualizados:
- ✅ `doc-001` (Constituição): Versão {{old}} → {{new}}
  - Atualizada seção "Estrutura de Diretórios"
  - Depreciado padrão `modules/`

### Novos Documentos Criados:
- ✅ `docs/standards/padroes-seguranca.backlog`
  - Define padrões de autenticação, validação, secrets

### ADRs Registradas:
- ✅ ADR-008: Migração de modules/ para components/
  - Status: Accepted
  - Consequências documentadas

### Basic Memory:
- ✅ Standard "Estrutura de Diretórios" sincronizado
- ✅ Nota persistida em Markdown

---

## 🎯 Ações de Follow-up

**Imediatas:**
- [ ] Refatorar imports em ~50 arquivos (modules/ → components/)
- [ ] Atualizar README.md com nova estrutura
- [ ] Comunicar mudanças ao time

**Médio Prazo:**
- [ ] Criar task para implementar padrões de segurança em módulos antigos
- [ ] Revisar outros padrões em 3 meses

---

## 📖 Documentação Atualizada

Consulte:
- Constituição: `backlog/docs/standards/constituicao.backlog`
- Padrões de Segurança: `backlog/docs/standards/padroes-seguranca.backlog`
- ADR-008: Via `backlog_decision_get("ADR-008")`
```

## Operações CRUD Completas (Resumo)

### CREATE (Criar documento)
```javascript
backlog_doc_create({
  title: "Título do Documento",
  type: "guide",  // ou "spec", "decision"
  path: "docs/standards/nome.backlog",  // ← .backlog OBRIGATÓRIO
  labels: ["standards"],
  content: "..."
})
```

### READ (Ler documento)
```javascript
// Por ID
const doc = backlog_doc_get("doc-001")

// Listar por filtro
const docs = backlog_doc_list({ path: "docs/standards/" })
const specs = backlog_doc_list({ type: "spec" })
```

### UPDATE (Atualizar documento)
```javascript
backlog_doc_update("doc-001", {
  content: "{{novo conteúdo}}",
  notes: "{{observações da atualização}}"
})
```

### DELETE (Deletar documento - RARO)
```javascript
// ⚠️ Verificar referências antes!
backlog_doc_delete("doc-005")
```

## Quando Usar?

- **Após concluir feature complexa** que trouxe aprendizados novos
- **Quando documentação está "descolada"** da realidade do código
- **Antes de iniciar épico/módulo grande** para alinhar expectativas
- **Após onboarding de novo membro** que identificou gaps na documentação
- **Periodicamente** (ex: trimestral) para manutenção preventiva

## Notas Importantes

- **Extensão .backlog Obrigatória**: TODOS os documentos de padrões DEVEM usar extensão `.backlog`, não `.md`
- **CRUD via MCP Exclusivo**: NUNCA editar arquivos `.backlog` manualmente - usar sempre ferramentas MCP
- **Versionamento**: Incrementar campo `version` no frontmatter ao fazer mudanças significativas
- **Rastreabilidade**: Registrar motivo das mudanças no campo `notes` ou criar ADR
- **Sincronização**: Padrões importantes devem ser espelhados no Basic Memory como notas do tipo "Standard"
- **Depreciação > Deleção**: Preferir marcar padrões como deprecados em vez de deletar documentos
- **Validação de Referências**: Antes de deletar documento, verificar se não há tasks/specs que o referenciam
- **ADRs para Decisões**: Mudanças arquiteturais significativas DEVEM ser documentadas como ADRs via `backlog_decision_create`
- **Comunicação**: Mudanças na Constituição devem ser comunicadas claramente ao time
- **Periodicidade**: Executar alinhamento ao menos trimestralmente para manter documentação atualizada
