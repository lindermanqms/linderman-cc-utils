---
description: Guia o processo de tomada de decisão arquitetural (ADR) e registra formalmente no projeto.
---
# Architectural Decision Record Assistant

1. **Entrevista**: Pergunte ao usuário:
   - Qual é o problema/contexto?
   - Quais são as opções consideradas?
   - Qual a opção escolhida e por quê?
2. **Rascunho**: Gere um texto formatado com:
   - **Título**: Claro e objetivo.
   - **Status**: Proposed ou Accepted.
   - **Contexto**: O "porquê".
   - **Consequências**: Pontos positivos e negativos da escolha.
3. **Registro**: Após aprovação, use `backlog_decision_create` para salvar a decisão formalmente no sistema de decisões.
4. **Link**: Se houver tasks relacionadas, atualize-as mencionando essa decisão nas notas ou dependências.
