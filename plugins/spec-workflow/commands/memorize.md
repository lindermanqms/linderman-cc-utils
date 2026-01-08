---
name: spec-memorize
description: Analisa o contexto atual da sessão para extrair aprendizados, erros e soluções, solicitando confirmação do usuário antes de salvar no Memory MCP.
---

# Memorização Manual e Curadoria de Conhecimento

Este comando permite que você capture insights e decisões técnicas importantes no meio de um fluxo de trabalho, ou consolide o que foi aprendido até agora.

## Procedimento de Análise

1.  **Exame de Contexto**:
    - O agente deve analisar as últimas interações, mensagens de erro (se houver), soluções implementadas e discussões técnicas.
    - Identificar padrões que podem ser úteis no futuro.

2.  **Identificação de Candidatos à Memória**:
    - **Erros & Soluções**: "O erro X foi causado por Y e resolvido com Z." -> `LessonLearned`.
    - **Decisões Técnicas**: "Optamos por usar a abordagem A em vez de B por causa de C." -> `ADR`.
    - **Padrões de Código**: "A partir de agora, as funções de API devem seguir este template." -> `Standard`.

3.  **Proposta ao Usuário**:
    - O agente deve apresentar uma lista do que identificou como digno de memória.
    - **Pergunta**: "Identifiquei os seguintes aprendizados. Quais deles você deseja salvar permanentemente no Grafo de Conhecimento?"
    - O usuário pode confirmar tudo, selecionar apenas alguns ou adicionar observações.

## Execução da Memorização

Após a aprovação do usuário:
1.  Use as ferramentas do **Memory MCP** (`create_entities`, `add_observations`, `create_relations`) para salvar as informações.
2.  Garanta a aderência ao **Padrão Estrito** de entidades.

## Saída Esperada

```
🧠 Análise de contexto concluída!
Proposta de memorização:
1. [ADR] Decisão sobre...
2. [LessonLearned] Erro de...
3. [Standard] Novo padrão para...

Deseja salvar estes itens? (Sim/Não/Editar)
```
