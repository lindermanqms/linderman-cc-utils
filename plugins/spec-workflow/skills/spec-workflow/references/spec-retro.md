# Spec-Driven Retrospective Knowledge Base

## O Valor do Fechamento
Fechar uma task não é apenas marcar um checkbox. É o momento de aprendizado e consolidação. No Spec-Driven Development, uma task só acaba quando o conhecimento gerado por ela é capturado no Grafo de Conhecimento do projeto.

## O Ritual de Retrospectiva (/spec-retro)

### 1. Quality Gate (AC Check)
Nenhuma task é `done` se os ACs não passaram.
*   O agente deve verificar explicitamente cada item da lista de ACs da Spec.
*   Testes automatizados devem estar verdes.

### 2. Relatório de Conclusão
O "Como foi feito" é tão importante quanto o "O que foi feito".
*   Um breve relatório deve ser gerado e anexado à task ou Spec.
*   Ele ajuda futuros desenvolvedores a entenderem o contexto histórico.

### 3. Jardinagem da Constituição e Memória
Este é o passo mais crítico. O conhecimento gerado deve ser indexado no Grafo de Conhecimento do projeto (**Memory MCP**) de forma assíncrona.

*   **Padrão Estrito**: O agente deve categorizar os aprendizados em:
    - **ADR (Architectural Decision Record)**: Para decisões técnicas significativas.
    - **LessonLearned**: Para insights e correções de erros.
    - **Standard**: Para novos padrões de código.
*   **Consolidação Assíncrona**: Ao rodar `/spec-retro`, o processo de atualização do grafo ocorre em background para não bloquear o fluxo de trabalho.

## Quando fazer manualmente?
Se o comando `/spec-retro` não estiver disponível:
1.  Verifique os ACs manualmente.
2.  Escreva um comentário na task resumindo a conclusão.
3.  Use as ferramentas do Memory MCP (`create_entities`, `add_observations`) para registrar o aprendizado seguindo o padrão estrito.
4.  Mova a task para `done` usando `backlog_task_update`.

## Ferramentas Relacionadas
*   `/spec-retro`: Comando principal (assíncrono para memória).
*   `Memory MCP`: `create_entities`, `add_observations`, `create_relations`.
*   `backlog_task_update`: Para finalizar a task no Backlog.
