---
description: Workflow de emergência para correção de bugs críticos. Cria uma task "fast-track", pula o planejamento detalhado e foca na correção imediata.
arg_name: bug-description
---

# Spec-Driven Hotfix Protocol 🚑

**MODO DE EMERGÊNCIA ATIVADO**
O objetivo é mitigar o problema imediatamente. A documentação perfeita fica para depois (via `/spec-retro`).

## FASE 1: Triagem Rápida
1.  **Criação Instantânea:**
    - Crie imediatamente uma task com label `hotfix` e prioridade `high` usando `backlog_task_create`.
    - Defina o status como "In Progress".
    - Capture o ID da task criada.

## FASE 2: Diagnóstico & Correção
Não peça "Plan" ou "ACs" complexos agora.
1.  **Reprodução:** Peça/Procure o erro. Crie um teste que falhe (se possível e rápido).
2.  **Correção:** Implemente o fix.
3.  **Verificação:** O erro parou? (Sim/Não).

## FASE 3: Encerramento Mínimo
Ao confirmar a correção:
1.  Atualize a task usando `backlog_task_update` com uma nota simples: "Correção aplicada via commit [hash]. Causa raiz: [resumo]."
2.  Mova para "Done".
3.  **Lembrete de Dívida Técnica:** Avise o usuário:
    *"Hotfix aplicado. Lembre-se de rodar `/spec-retro` ou `/spec-refine` depois para garantir que a documentação/testes de regressão sejam atualizados com calma."*
