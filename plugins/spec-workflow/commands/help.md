---
name: spec-help
description: Exibe ajuda sobre o fluxo de trabalho Spec-Driven Development e lista os comandos disponíveis.
version: 0.1.0
category: workflow
triggers:
  - "/spec-help"
  - "ajuda spec"
  - "comandos spec"
  - "como usar spec"
---

# Spec-Driven Development Help

Este plugin implementa a filosofia **Spec-Driven Development** (Desenvolvimento Guiado por Especificação), onde a documentação precede e guia o código.

## Comandos Disponíveis

### Ciclo de Vida Principal

1.  **/spec-init**
    *   **Objetivo:** Inicializar o backlog e configurar o projeto.
    *   **Uso:** Execute no início de um novo projeto.
    *   **Ação:** Cria o arquivo de backlog e configura o diretório `.claude/`.

2.  **/spec-plan**
    *   **Objetivo:** Planejar uma nova feature ou mudança.
    *   **Uso:** `/spec-plan "Descrição da feature"`
    *   **Ação:** Cria uma task no backlog e gera um documento de Especificação (Spec Doc) detalhando o "O Que" e o "Porquê".

3.  **/spec-execute**
    *   **Objetivo:** Executar uma task planejada.
    *   **Uso:** `/spec-execute <task-id>`
    *   **Ação:** Lê a Spec, quebra em subtarefas técnicas (se necessário) e guia a implementação.

4.  **/spec-retro**
    *   **Objetivo:** Finalizar uma task e realizar retrospectiva.
    *   **Uso:** `/spec-retro <task-id>`
    *   **Ação:** Verifica ACs, gera relatório de conclusão e atualiza a documentação global (Constituição) com aprendizados.

### Comandos de Gestão e Auditoria

5.  **/spec-replan**
    *   **Objetivo:** Reestruturar o backlog após uma mudança crítica.
    *   **Uso:** `/spec-replan "Nova realidade do projeto"`
    *   **Ação:** Identifica tarefas obsoletas, mutantes e novas necessidades.

6.  **/spec-review**
    *   **Objetivo:** Revisar a conformidade da task antes de fechar.
    *   **Uso:** `/spec-review <task-id>`
    *   **Ação:** Verifica Critérios de Aceite (ACs) e conformidade com a Constituição.

7.  **/spec-align**
    *   **Objetivo:** Sincronizar a documentação com a realidade do código.
    *   **Uso:** `/spec-align`
    *   **Ação:** Discute e atualiza os padrões do projeto (A Constituição).

### Comandos Auxiliares (Futuros/Em Desenvolvimento)

*   **/spec-clean**: Limpeza e jardinagem do backlog.
*   **/spec-standup**: Resumo do status atual.

## Filosofia "Document-Centric" & "MCP-Only"

*   **Documentos são a Verdade:** Tasks são apenas containers/ponteiros. A inteligência real vive em arquivos Markdown (Specs) linkados às tasks.
*   **Gestão via MCP:** Toda manipulação de tarefas é feita via ferramentas MCP (`backlog_task_create`, `backlog_doc_create`), nunca via edição manual de texto ou CLI.
*   **Memória Automatizada:** O sistema mantém o contexto atualizado para reduzir a carga cognitiva.

## Como começar?

Se este é um projeto novo, comece rodando:
`/spec-init`
