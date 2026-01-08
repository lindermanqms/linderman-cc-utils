---
name: spec-align
description: Sessão de alinhamento estratégico para discutir e atualizar a "Constituição" do projeto com base na realidade do código.
version: 0.1.0
category: workflow
triggers:
  - "/spec-align"
  - "alinhamento estratégico"
  - "revisar padrões"
  - "discutir arquitetura"
---

# Spec-Align: Alinhamento Estratégico e Evolução de Padrões

O `/spec-align` é um espaço para reflexão sobre os rumos do projeto e a eficácia dos padrões estabelecidos (A Constituição).

## Workflow de Alinhamento

### 1. Panorama Atual
- Liste as guias de padrões e documentos de arquitetura atuais (`backlog_doc_list`).
- Resuma as últimas grandes decisões tomadas (`backlog_decision_list`).

### 2. Provocação e Reality Check
O agente deve questionar o usuário ou trazer observações do código:
- "Os padrões definidos em [Documento X] estão sendo seguidos ou tornaram-se um estorvo?"
- "Notei que a implementação de [Feature Y] divergiu da nossa arquitetura base. Devemos atualizar a documentação ou corrigir o código?"
- "Existe alguma nova tecnologia ou padrão que deveríamos adotar?"

### 3. Proposta de Atualização
Com base na discussão, o agente propõe:
- **Novas Regras:** Adição de novos itens à Constituição.
- **Depreciações:** Remoção de padrões obsoletos.
- **Novas ADRs:** Registro formal de decisões arquiteturais via `backlog_decision_create`.

### 4. Formalização
- Atualize os arquivos de padrões relevantes.
- Comunique as mudanças ao usuário de forma clara.

## Quando usar?
- Após concluir uma feature complexa que trouxe aprendizados novos.
- Quando o time sente que a documentação está "descolada" da realidade.
- Antes de iniciar um novo épico ou grande módulo.

## Exemplo de Output:
```markdown
⚖️ **Sessão de Alinhamento Estratégico**

**Tópicos em Discussão:**
1. Transição para [Nova Tecnologia]
2. Refinamento de padrões de tratamento de erros
3. Revisão do fluxo de CI/CD

**Ações Sugeridas:**
- [ ] Atualizar `docs/standards/backend.md`
- [ ] Criar ADR-005 sobre [Decisão]
```
