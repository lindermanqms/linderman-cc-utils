---
name: spec-review
description: Examina a conformidade do código com a "Constituição" do projeto e os requisitos específicos da task.
version: 0.1.0
category: workflow
triggers:
  - "/spec-review"
  - "revisar task"
  - "review de código"
arguments:
  - name: task-id
    description: ID da task a ser revisada
    required: true
---

# Spec-Review: Auditoria de Conformidade e Qualidade

Este comando realiza uma revisão rigorosa antes da finalização de uma task, garantindo que o código não apenas funcione, mas siga todos os padrões estabelecidos.

## Instruções para o Agente

### 1. Preparação
- Leia os detalhes da task `{{task-id}}` usando `backlog_task_get`.
- Localize e leia o documento de **Spec** associado (mencionado no campo `plan` ou nos documentos do projeto).
- Identifique os arquivos da **"Constituição"** do projeto (geralmente em `docs/standards/`, `backlog/docs/` ou arquivos como `CLAUDE.md`).

### 2. Auditoria Técnica
- **Verificação de ACs:** Para cada Critério de Aceite da task, verifique no código se a implementação está completa e correta.
- **Alinhamento Arquitetural:** O código respeita a arquitetura proposta na Spec e os padrões globais do projeto?
- **Qualidade e Limpeza:**
  - Existem comentários `TODO`, `FIXME` ou logs de debug remanescentes?
  - A nomenclatura segue as convenções do projeto?
  - A cobertura de testes (se exigida) é adequada?

### 3. Relatório de Conformidade (Conformity Report)

Apresente o resultado da revisão para o usuário:

```markdown
🔍 **Relatório de Revisão: Task {{task-id}}**

**Status dos Critérios de Aceite (ACs):**
- [✅] AC1: [Nome do AC] - Verificado em `caminho/do/arquivo`
- [❌] AC2: [Nome do AC] - [Explicação do que falta ou está incorreto]

**Conformidade com a Constituição:**
- [✅] Padrões de Nomenclatura
- [⚠️] Arquitetura: [Observação sobre possível desvio]
- [✅] Testes Automatizados

**Veredito:**
- 🔴 **REFUSED:** [Motivo principal do bloqueio]
- 🟢 **APPROVED:** [Parabéns e sugestões menores]
```

### 4. Próximos Passos
- Se **REFUSED**: Liste as correções necessárias e mantenha a task em `in_progress`.
- Se **APPROVED**: Sugira o uso de `/spec-retro {{task-id}}` para encerrar a tarefa formalmente.

## Notas
- Seja crítico e detalhista.
- Aponte trechos específicos de código que precisam de atenção.
- Não aprove se houver falhas óbvias nos requisitos da Spec.
