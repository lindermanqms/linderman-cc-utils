---
name: spec-init
description: Initialize Spec-Driven Development environment with Backlog and Memory MCP, adapting to existing structures.
version: 3.1.0
category: workflow
triggers:
  - "/spec-init"
  - "iniciar spec"
  - "configurar spec"
  - "instalar spec"
---

# Spec Init - Initialize Spec-Driven Environment

This command initializes or updates the Spec-Driven Development workflow in the project. It is designed to be idempotent and safe to run on existing projects.

## What It Does

1.  **Smart Analysis**: Analyzes existing `Backlog.md`, `CLAUDE.md`, and legacy `.cipher/` directory.
2.  **Legacy Cleanup**: Detects and suggests removal of Cypher configurations and directories.
3.  **Memory Setup**: Initializes the **Memory MCP** knowledge graph with a strict schema.
4.  **Robust Backlog Setup**: Creates or updates `Backlog.md`, ensuring required sections exist.
5.  **Imperative CLAUDE.md Update**: Injects mandatory guidelines for using memory and skills.
6.  **Structure Enforcement**: Guarantees existence of `backlog/specs` and `backlog/docs`.

## Workflow Steps

### 1. Inicialização do Backlog via Script
Execute o script de inicialização robusto localizado no plugin:
`bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-project.sh`

Este script garante a instalação do `backlog.md`, inicializa o projeto com integração MCP e aplica o template obrigatório no `Backlog.md`.

### 2. Memory Knowledge Graph Boot
Initialize a memória do projeto usando o servidor **Memory MCP**:
1.  **Create Root Entity**: `create_entities([{name: "Project Root", entityType: "Project", observations: ["Iniciado via /spec-init"]}])`.
2.  **Define Strict Schema**: Registre as entidades: `Project`, `Standard`, `ADR`, `TechStack`, `LessonLearned`.

### 3. Imperative CLAUDE.md Update
Atualize o `CLAUDE.md` da raiz do projeto para incluir as regras imperativas de uso do MCP e do fluxo Spec-Driven.

### 5. Imperative CLAUDE.md Update

**Content to Inject/Update (MUST be in Portuguese):**
```markdown
# Memory & Spec Workflow (IMPERATIVO)

Este projeto utiliza Spec-Driven Development com Memory MCP. O cumprimento destas regras é obrigatório para evitar a repetição de erros e garantir a consistência técnica.

## Padrão Estrito de Memória
Toda informação relevante deve ser salva no Grafo de Conhecimento usando as entidades:
- **Project**: Visão geral e objetivos.
- **Standard**: Padrões de código e convenções.
- **ADR**: Architectural Decision Records (Decisões técnicas e porquês).
- **TechStack**: Tecnologias e versões.
- **LessonLearned**: Aprendizados de retrospectivas e soluções de bugs.

## Regras de Execução
1. **CONSULTA OBRIGATÓRIA**: Antes de iniciar qualquer tarefa ou propor mudanças arquiteturais, você DEVE usar `read_graph` ou `search_nodes`. É imperativo verificar se já existem lições aprendidas (`LessonLearned`) ou decisões (`ADR`) que impactem o trabalho atual.
2. **USO DE SKILLS**: Sempre que disponíveis, utilize as skills do plugin (`/spec-plan`, `/spec-execute`, `/spec-retro`, `/spec-memorize`) em vez de comandos manuais.
3. **CONSOLIDAÇÃO OBRIGATÓRIA**: Ao finalizar uma tarefa ou descobrir um erro crítico, use `/spec-retro` ou `/spec-memorize`. O conhecimento deve ser estruturado no grafo para que não seja perdido.
```

### 6. Directory Structure

Ensure `backlog/specs` and `backlog/docs` exist.

## Success Message

```
✅ Spec-Driven Development environment updated with Memory MCP!

- 📋 Backlog: [Created | Updated | Verified]
- 🧠 Memory: Initialized strict schema (Obrigatório).
- 📁 Structure: verified `backlog/specs` & `backlog/docs`
- 🤖 CLAUDE.md: [Updated] with IMPERATIVE Memory Pattern.

🚀 Ready to use! Try `/spec-help`.
```
