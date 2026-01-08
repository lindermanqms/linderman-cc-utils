---
description: Realiza uma sessão de Alinhamento Estratégico. Revisa a meta macro, reprioriza o backlog e recalibra a direção do projeto.
---

# Spec-Driven Strategic Alignment

Você vai conduzir uma sessão de **Alinhamento**. O objetivo é garantir que estamos construindo a coisa certa, na ordem certa, e se a direção precisa mudar.

## FASE 1: O "Norte Verdadeiro"
1.  **Objetivo Atual:** Pergunte ao usuário: *"Qual é a meta principal deste ciclo/momento? (ex: Lançar MVP, Estabilizar Produção, Refatorar Core)"*
2.  **Raio-X do Backlog:**
    - Analise o que está em "To Do" (use `backlog_task_list` e filtre por status).
    - Analise o que está em "In Progress" (para ver se algo deve ser pausado/cancelado em prol da nova meta).

## FASE 2: A Calibragem (Revisão & Priorização)
Com base na META declarada pelo usuário e no BACKLOG atual:

1.  **Validação de Relevância:**
    - *Analise:* As tarefas no topo da fila contribuem para a Meta atual?
    - *Desvio:* Se houver tarefas irrelevantes no topo, sugira movê-las para baixo ou para o backlog profundo.
    - *Lacuna:* Falta alguma tarefa óbvia para atingir a meta? Sugira criar.

2.  **Reordenamento:**
    - Proponha uma nova fila de execução otimizada.
    - Identifique dependências bloqueantes que exigem mudança de ordem.

## FASE 3: O Novo Pacto
Gere o plano de ação estratégico:

> 🧭 **Alinhamento Estratégico: [Nome da Meta]**
>
> **Foco Imediato (Must Do):**
> 1. [TASK-10] (Prioridade Alta - Alinhado à Meta)
> 2. [TASK-15] (Bloqueante Crítico)
>
> **Foco Secundário (Next Up):**
> 3. [TASK-02]
>
> **Pausar / Adiar (Desalinhado):**
> *   Sugiro pausar a [TASK-99] pois foge da meta atual.
>
> **Ações de Correção:**
> *   [ ] Criar Task "Setup Infra" (Faltava para a meta).
> *   [ ] Rebaixar prioridade da Task-99.
>
> *Posso aplicar essas mudanças de prioridade e criação no Backlog?*

Se o usuário aprovar, execute as criações e edições necessárias usando `backlog_task_create` e `backlog_task_update` para refletir esse novo alinhamento.
