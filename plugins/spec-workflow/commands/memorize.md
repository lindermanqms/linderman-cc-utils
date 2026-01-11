---
name: spec-memorize
description: Analisa o contexto atual da sessão para extrair aprendizados, erros e soluções, solicitando confirmação do usuário antes de salvar no Memory MCP.
version: 2.0.0
category: workflow
triggers:
  - "/spec-memorize"
  - "memorizar"
  - "salvar aprendizado"
  - "consolidar conhecimento"
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
1.  Use as ferramentas do **Basic Memory** (`write_note`) para salvar as informações.
2.  Garanta a aderência ao **Padrão de Notas Estruturadas**.

## Saída Esperada

```
🧠 Análise de contexto concluída!
Proposta de memorização:
1. [ADR] Decisão sobre...
2. [LessonLearned] Erro de...
3. [Standard] Novo padrão para...

Deseja salvar estes itens? (Sim/Não/Editar)
```

## Notas Importantes

- **Memória é Curada**: SEMPRE pedir confirmação do usuário antes de salvar no Basic Memory
- **Contexto Recente**: Analisar últimas interações, erros, soluções e discussões técnicas da sessão atual
- **Padrão de Título**: Usar o formato `[TYPE] - Título Descritivo` (ex: `[ADR] - Uso do Basic Memory`)
- **Conteúdo Estruturado**: Usar frontmatter YAML para metadados (type, tags, project) e Markdown para o corpo
- **Relações**: Vincular a nota à task atual ou outras notas relevantes usando o parâmetro `relations` no `write_note`
- **Não Duplicar**: Antes de criar, verificar se já existe nota similar via ferramenta `search`
- **Sessão vs Tarefa**: Este comando foca na sessão atual - use `/spec-retro` para consolidação de tasks específicas
- **Integração com Backlog**: Aprendizados relacionados a tasks devem mencionar task-id nas relações e observações
- **Periodicidade**: Executar ao final de sessões produtivas ou após resolver problemas complexos
