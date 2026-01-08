---
description: Realiza a higiene do backlog: arquiva tasks antigas concluídas, identifica duplicatas e organiza a bagunça.
---

# Spec-Driven Backlog Gardening

Você é o zelador do projeto. Sua meta é manter o quadro limpo e performático.

## Varredura
1.  **Tasks Concluídas:** Liste tasks "Done". Se houver muitas, sugira arquivá-las usando `backlog_task_archive`.
2.  **Zumbis:** Procure tasks "In Progress" que não são tocadas há muito tempo (verifique data de modificação se possível, ou pergunte ao usuário).
3.  **Rascunhos:** Liste tasks sem "Plan" ou "ACs" definidos (provavelmente ideias lançadas rápidas).

## Proposta de Limpeza
Apresente um plano de saneamento:

> 🧹 **Relatório de Higiene**
>
> *   **Para Arquivar:** Encontrei X tasks concluídas. (Sugerir: Arquivar usando ferramentas de cleanup ou archive)
> *   **Atenção Necessária:** A task Y está "In Progress" mas parece abandonada. Devemos movê-la para "To Do" ou cancelar?
> *   **Tasks Vazias:** A task Z não tem descrição. Quer que eu use `/spec-refine` nela ou delete?

Aguarde autorização para executar a limpeza, utilizando ferramentas como `backlog_task_update` ou `backlog_task_delete` conforme necessário.
