---
description: Reestrutura o backlog em resposta a uma mudança crítica de cenário. Identifica tarefas obsoletas para arquivar, specs que precisam de reescrita e novas lacunas.
arg_name: critical-change
---

# Spec-Driven Replanning Protocol 🔄

**SITUAÇÃO:** O cenário mudou. O plano anterior está comprometido.
**NOVO CONTEXTO:** "{{critical-change}}"

## FASE 1: Análise de Impacto (Triagem)
1.  **Leitura do Cenário:** Entenda profundamente o `{{critical-change}}`.
2.  **Scan do Backlog:**
    - Use `backlog_task_list` para ver tarefas "In Progress" (Prioridade Máxima: devemos parar algo?).
    - Liste tarefas "To Do".
3.  **Check de Constituição:**
    - O novo contexto invalida nossa documentação atual (`project/standards`)?

## FASE 2: O Filtro (Auditoria de Sobrevivência)
Para cada tarefa listada, aplique o filtro do Novo Contexto:

*   **OBSOLETA (Kill):** A tarefa não faz mais sentido? (Ex: "Configurar MySQL" sendo que mudamos para Postgres).
*   **MUTANTE (Update):** A tarefa ainda existe, mas a Spec mudou radicalmente?
*   **LACUNA (New):** O novo contexto exige tarefas que não existiam?

## FASE 3: O Plano de Reestruturação
Apresente o relatório de mudanças para aprovação:

> 🚨 **Relatório de Impacto: Mudança de Cenário**
>
> **1. Documentação (A Constituição)**
> *   [ ] Atualizar `project/standards` para refletir: "{{critical-change}}".
> *   [ ] Criar ADR/Decision (via `backlog_decision_create`) registrando a mudança de rumo.
>
> **2. Ações Destrutivas (Limpeza)**
> *   🛑 **Arquivar/Cancelar:**
>     *   `TASK-10` (Motivo: Incompatível com nova tech)
>     *   `TASK-12` (Motivo: Feature cancelada pelo cliente)
>
> **3. Ações de Modificação (Refinamento)**
> *   ✏️ **Reescrever Spec:**
>     *   `TASK-15`: Alterar descrição para remover referência à tecnologia antiga.
>
> **4. Ações Construtivas (Novas Tasks)**
> *   ✨ **Criar:**
>     *   `[Título Nova Task 1]`
>     *   `[Título Nova Task 2]`
>
> **Ações:**
> Sugira o uso de `backlog_task_archive`, `backlog_task_update` e `backlog_task_create` para executar o plano.
>
> *Posso executar essa cirurgia no backlog e atualizar a documentação?*
