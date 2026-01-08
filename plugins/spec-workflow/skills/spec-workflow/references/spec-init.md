# Spec-Driven Initialization Knowledge Base

## Conceito
A inicialização de um projeto Spec-Driven não é apenas criar pastas. É estabelecer a "Constituição" do projeto e garantir que o fluxo de trabalho esteja configurado para priorizar a documentação.

## O Processo de Inicialização

O comando `/spec-init` executa um script de automação (`init-project.sh`) que:
1.  **Verifica Dependências**: Garante que o `backlog.md` está instalado globalmente.
2.  **Configura o Projeto**: Executa `backlog init` com integração MCP ativada.
3.  **Estabelece o Template**: Cria o arquivo `Backlog.md` com as seções obrigatórias de Specs e Constituição.
4.  **Organiza Pastas**: Cria `backlog/specs` e `backlog/docs`.

### A Constituição (Backlog.md)
O arquivo `Backlog.md` deve seguir este template exato:

```markdown
# Backlog

## 📦 Specs
<!--
As Specs são documentos vivos que descrevem features, melhorias ou correções antes de qualquer código ser escrito.
Elas seguem o padrão SPEC-{ID}: {Nome da Feature}.
-->

## 🏛️ Constituição do Projeto
<!--
A Constituição define as regras inegociáveis do projeto, padrões de código, arquitetura e convenções que devem ser seguidas.
-->
```

## Ferramentas MCP para Inicialização
Sempre prefira usar ferramentas MCP como `document_create` para adicionar novos documentos de padrão ou guias à Constituição após a inicialização inicial.

### 3. Configuração do Agente e Memória
O arquivo `CLAUDE.md` é atualizado para instruir o agente a:
*   Nunca codar sem ler a Spec.
*   Usar ferramentas MCP para gerenciar o backlog e o grafo de memória.
*   Respeitar o **Padrão Estrito de Memória** (Project, Standard, ADR, TechStack, LessonLearned).
*   Consultar o grafo (`read_graph`) antes de grandes decisões.

## Quando rodar manualmente?
Normalmente você usa o comando `/spec-init`. Mas se precisar consertar algo manualmente:

*   **Se o backlog sumiu:** Recrie a pasta `backlog/` e rode o init.
*   **Se o agente ignora regras:** Verifique se o `CLAUDE.md` contém a seção de "Workflow Spec-Driven".
*   **Se faltam docs:** Use `backlog_doc_create` para criar os documentos faltantes.

## Ferramentas Relacionadas
*   `/spec-init`: Comando principal de automação.
*   `backlog_doc_create`: Ferramenta MCP para criar documentos avulsos.
