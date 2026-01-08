---
description: Gera um relatório de status imediato (Daily Standup), resumindo o que está em progresso, bloqueios e o que foi concluído recentemente.
---

# Spec-Driven Standup Report

Você deve agir como um Scrum Master eficiente. Analise o estado do projeto e me dê um resumo curto e denso.

## Procedimento
1.  **Scan:** Utilize `backlog_board_view` ou `backlog_task_list` para ter uma visão geral.
2.  **Deep Dive (In Progress):** Para cada task na coluna "In Progress", leia as últimas notas/comentários (`backlog_task_get`).
3.  **Bloqueios:** Verifique se há tasks com tags/labels `blocked` ou `bug`.
4.  **Recentes:** Verifique o que foi movido para "Done" nas últimas 24h (se possível inferir pelas notas ou histórico).

## Output (O Relatório)
Gere um resumo no seguinte formato:

> 🌅 **Daily Standup: [Data/Hora]**
>
> 🚧 **Em Andamento (Foco Atual)**
> *   **[TASK-ID] Título**
>     *   *Status Real:* "O agente parou na implementação do AC 2." (Baseado nas notas)
>     *   *Próximo Passo:* O que falta para fechar?
>
> ✅ **Concluído Recentemente**
> *   [Lista rápida]
>
> 🛑 **Bloqueios/Riscos**
> *   [Se houver dependências quebradas ou bugs críticos abertos]
>
> **Sugestão do Dia:** "Baseado nisso, recomendo retomar a TASK-X..."
