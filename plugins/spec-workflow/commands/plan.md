---
name: spec-plan
description: Inicia o processo de planejamento de uma nova feature ou task macro, criando a Spec e a tarefa correspondente via MCP.
version: 0.2.0
category: workflow
triggers:
  - "/spec-plan"
  - "planejar feature"
  - "criar spec"
  - "novo planejamento"
arguments:
  - name: feature-name
    description: Nome da feature ou task a ser planejada.
    required: false
---

# Spec-Plan: Planejamento de Feature com Spec Document

Este comando guia a criação de uma **Spec completa** utilizando o servidor MCP do Backlog.

## Workflow OBRIGATÓRIO

### Fase 1: Levantamento de Requisitos
1. **Perguntas Chave**: Não avance sem entender o Objetivo, Usuários, Escopo e Restrições.
2. **Consulta MCP**:
   - Use `document_list` para ler a **Constituição** e padrões existentes.
   - Use `task_list` para evitar duplicidade.

### Fase 2: Criação da Task Macro via MCP
Use `task_create` para criar o "Epic" ou "Feature" no backlog.
- **Título**: `[SPEC] Nome da Feature`
- **Labels**: `spec`, `planning`
- **Priority**: Definida com o usuário.

### Fase 3: Criação do Spec Document via MCP
Use `document_create` para criar o documento detalhado.
- **Path**: `specs/SPEC-ID-nome-da-feature.md`
- **Conteúdo**: Siga o template estruturado (Contexto, Solução, Detalhamento Técnico, Critérios de Aceite (AC), Casos de Borda, Testes).

### Fase 4: Vinculação
Atualize a task criada na Fase 2 usando `task_edit` para incluir o link para o documento da Spec no campo `description` ou `plan`.

## Template do Spec Document
```markdown
# SPEC-ID: Nome da Feature
**Status:** 📝 Draft
**Task Relacionada:** #ID

## 1. Contexto e Motivação
[Problema e Objetivos]

## 2. Proposta de Solução
[Arquitetura e Fluxo de Dados]

## 3. Critérios de Aceite (AC)
- [ ] AC1: ...
- [ ] AC2: ...

## 4. Casos de Borda e Erros
[Cenários de falha]

## 5. Estratégia de Testes
[Unitários, Integração]
```

## Regras de Ouro
- **MCP-Only**: Proibido editar arquivos Markdown diretamente.
- **ACs são Contratos**: Seja exaustivo nos Critérios de Aceite.
- **Memória**: Após aprovação da Spec, registre decisões arquiteturais importantes no Memory MCP.
