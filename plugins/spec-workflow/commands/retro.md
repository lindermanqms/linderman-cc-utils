---
name: spec-retro
description: Finaliza uma task, verifica ACs, gera relatório de conclusão e consolida a memória do projeto de forma assíncrona.
version: 0.1.0
category: workflow
triggers:
  - "/spec-retro"
  - "finalizar task"
  - "retrospectiva"
  - "fechar task"
arguments:
  - name: task_id
    description: ID da task a ser finalizada (ex: T-1)
    required: true
---

# Retrospectiva Assíncrona: {{task_id}}

Este comando encerra o ciclo de vida de uma task, garantindo que o conhecimento gerado seja capturado sem bloquear seu fluxo de trabalho.

## Procedimento Principal (Síncrono)

1.  **Quality Gate (AC Check)**:
    - Verifique explicitamente se todos os Critérios de Aceite da Spec de {{task_id}} foram atingidos.
    - Se houver pendências, informe o usuário e interrompa o fechamento.

2.  **Relatório de Conclusão**:
    - Gere um breve resumo (Markdown) das decisões técnicas e lições aprendidas.
    - Anexe à Spec ou salve em `backlog/docs/`.

3.  **Fechamento de Task**:
    - Use `backlog_task_update` para mudar o status de {{task_id}} para `done`.

## Consolidação de Memória (Assíncrona)

**IMPORTANTE**: Imediatamente após os passos acima, dispare a consolidação da memória em background.

**Ação do Subagente de Background**:
1.  **Análise de Contexto**: Analisa o `git diff` e o log da conversa para extrair conhecimento estruturado.
2.  **Sincronização com o Grafo (Memory MCP)**:
    - Criar ou atualizar entidades do tipo `LessonLearned`.
    - Registrar novos `ADR` se decisões arquiteturais foram tomadas.
    - Atualizar `TechStack` se novas libs foram introduzidas.
    - Criar relações (`REFERS_TO`) entre a task concluída e os arquivos/entidades modificados.
3.  **Finalização Silenciosa**: O subagente encerra sua execução após garantir que o grafo está atualizado.

## Saída Esperada

O terminal deve ser liberado rapidamente com a mensagem:
```
✅ Task {{task_id}} marcada como concluída!
📝 Relatório gerado em [link].
🧠 Memória do projeto sendo consolidada em background...
```
