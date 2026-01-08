# Spec Refinement Knowledge Base

## O Que é Refinamento?
Refinamento é o processo de transformar uma ideia vaga ("Melhorar login") em uma Especificação Técnica robusta e acionável. É a ponte entre o "Querer" e o "Fazer".

## O Processo de Refinamento (/spec-refine ou /spec-plan)

### 1. Análise de Intenção
O primeiro passo é entender o problema raiz.
*   Não aceite soluções prontas ("Coloque um botão ali").
*   Entenda a dor ("O usuário não consegue achar a função X").

### 2. O Documento de Especificação (Spec Doc)
O produto final do refinamento deve ser uma Spec bem definida (na própria task ou em arquivo markdown em `backlog/specs/` se complexo). Deve conter:
*   **Contexto:** Por que estamos fazendo isso?
*   **Fluxo de Usuário:** O passo a passo.
*   **Critérios de Aceite (ACs):** Lista binária (Sim/Não) para validar a entrega.
*   **Edge Cases:** O que acontece se a internet cair? Se o dado for inválido?

### 3. Cross-Check com a Constituição
Uma Spec não vive no vácuo. Ela deve respeitar as leis do projeto.
*   Verifique `docs/project/standards.md` (ou similar).
*   A solução proposta viola alguma regra de arquitetura?
*   Se sim, ou mude a solução, ou proponha uma emenda à Constituição.

## Ferramentas Relacionadas
*   Use `backlog_task_update` para adicionar detalhes, planos e ACs à task.
*   Use `backlog_doc_create` se for necessário criar um documento de Spec separado.
