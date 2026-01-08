---
description: Cria uma tarefa de correção (bug ou refatoração) com alta prioridade, focando não só no código, mas na correção da Documentação/Padrões que permitiram o erro.
arg_name: problem-description
---

# Spec-Driven Correction Protocol 🛠️

Este comando trata de correções onde o resultado atual é insatisfatório ou bugado.
A premissa é: **"Se o código está ruim, o Padrão (Spec/Doc) permitiu isso."**

## FASE 1: Análise de Causa (O "Porquê")
1.  **Contexto:** O usuário reportou: *"{{problem-description}}"*.
2.  **Investigação da Constituição:**
    - Verifique arquivos em `backlog/docs/` (ex: `project/standards`).
    - Pergunte-se: *O padrão atual induziu a esse erro? O padrão está vago? Ou o padrão foi ignorado?*

## FASE 2: Definição da Solução Dupla
Todo `/spec-fix` deve gerar uma proposta com duas pernas:

1.  **A Correção do Código (Refatoração/Bugfix):**
    - O que será alterado no código para resolver o problema imediato.
2.  **A Correção do Processo (Vacina):**
    - Qual regra deve ser adicionada ou alterada na documentação para que o agente (ou outro dev) não cometa esse erro novamente?

## FASE 3: Criação da Task de Correção
Proponha a criação de uma Task Estruturada:

> 🔧 **Proposta de Correção (Spec-Fix)**
>
> **O Problema:** [Resumo]
> **A Causa Raiz:** [Falha no Padrão / Padrão Ignorado / Padrão Inexistente]
>
> **📋 Estrutura da Task Sugerida**
> *   **Título:** `FIX: [Descrição Curta]`
> *   **Prioridade:** `High` (Correções têm preferência)
> *   **Labels:** `bug`, `refactor`, `process-improvement`
>
> *   **Subtarefa 1 (Código):** Implementar a correção/refatoração.
> *   **Subtarefa 2 (Constituição):** Atualizar o doc `project/standards` com a nova regra: *"[Descreva a nova regra]"*.
>
> **Ação:**
> (Gere as tasks usando `backlog_task_create` com as subtasks já definidas)
>
> *Posso criar essa task de correção e atualização de processo?*
