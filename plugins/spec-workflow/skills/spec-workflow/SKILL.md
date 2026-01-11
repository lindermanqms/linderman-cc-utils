---
name: spec-workflow
description: Conjunto de skills para Spec-Driven Development. Use quando o usuário quiser criar specs, planejar tarefas, executar implementações complexas, ou gerenciar o backlog usando a metodologia Spec-Driven. Trigger phrases: "criar spec", "planejar feature", "executar task", "workflow spec", "backlog management", "spec retro", "alinhar projeto".
version: 0.2.0
---

# Spec-Driven Development Workflow

Esta skill guia o desenvolvimento focado em especificações claras (Specs) antes da codificação, utilizando `Backlog.md` para gestão e **Memory MCP** para um Grafo de Conhecimento estruturado.

## Fluxo Principal

O workflow é composto por etapas distintas, cada uma suportada por documentos de referência específicos:

1.  **Inicialização & Alinhamento** (`/spec-init`, `/spec-align`)
    *   Configura o ambiente e alinha expectativas do projeto.
    *   Define a "Constituição" do projeto (regras, padrões).
    *   Inicializa a memória estruturada no Memory MCP.

2.  **Planejamento & Especificação** (`/spec-plan`)
    *   **Spec First:** Nenhuma linha de código é escrita sem uma Spec aprovada.
    *   **Document-Centric:** Cada Feature ou Task Macro deve ter seu próprio documento de Spec (`backlog/specs/ID-nome.md`).
    *   O agente consulta o grafo de memória para garantir consistência com padrões e ADRs existentes.

3.  **Refinamento** (`/spec-refine`)
    *   Transforma rascunhos em Specs detalhadas com Critérios de Aceite (AC).
    *   Define cenários de borda e estratégias de teste.

4.  **Execução** (`/spec-execute`)
    *   Quebra a Spec em subtarefas técnicas executáveis.
    *   Implementação segue estritamente a Spec.

5.  **Revisão & Retrospectiva** (`/spec-review`, `/spec-retro`)
    *   Verifica se a implementação atende a todos os ACs da Spec.
    *   Gera Relatório de Conclusão.
    *   **Consolidação de Memória:** Atualiza o grafo (**Memory MCP**) com aprendizados (LessonLearned) e decisões (ADR) de forma assíncrona.

## Ferramentas MCP Obrigatórias

Para qualquer interação com o Backlog, você **DEVE** utilizar o servidor MCP `backlog`. É estritamente proibido editar arquivos Markdown na pasta `backlog/` ou o arquivo `Backlog.md` manualmente para gerenciar tarefas.

As ferramentas disponíveis incluem:
- `backlog_task_create`: Criar novas tarefas.
- `backlog_task_list`: Listar tarefas existentes.
- `backlog_task_get`: Ver detalhes de uma tarefa.
- `backlog_task_update`: Atualizar metadados de uma tarefa ou marcar como concluída (com `status: "Done"`).
- `backlog_task_archive`: Arquivar tarefa.
- `backlog_doc_create`: Criar documentos técnicos ou Specs.
- `backlog_doc_get`: Ler conteúdo de documentos.
- `backlog_doc_list`: Listar documentos disponíveis.
- `backlog_decision_create`: Criar ADRs (Architecture Decision Records).

O servidor MCP é a fonte da verdade e é sincronizado automaticamente com os arquivos Markdown.

## Referências Detalhadas

Para detalhes de cada etapa, o Claude carregará o contexto necessário das referências:
- `spec-init`: Inicialização do projeto e migração de memória.
- `spec-plan`: Planejamento de novas features com consulta ao grafo.
- `spec-execute`: Execução passo-a-passo.
- `spec-refine`: Criação de documentos de especificação.
- `spec-retro`: Processo de retrospectiva assíncrona e aprendizado.
