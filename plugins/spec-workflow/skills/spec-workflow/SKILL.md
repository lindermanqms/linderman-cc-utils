---
name: spec-workflow
description: Conjunto de skills para Spec-Driven Development. Use quando o usuário quiser criar specs, planejar tarefas, executar implementações complexas, ou gerenciar o backlog usando a metodologia Spec-Driven. Trigger phrases: "criar spec", "planejar feature", "executar task", "workflow spec", "backlog management", "spec retro", "alinhar projeto".
version: 0.3.0
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
    *   **Main Task + Subtasks:** Cria a tarefa principal e já a divide em passos atômicos (subtasks) com `parent` link.
    *   **Document-Centric:** Cada Feature deve ter seu próprio documento de Spec com extensão **`.backlog`** (OBRIGATÓRIA) em `specs/SPEC-ID-nome.backlog`.
    *   O agente consulta o grafo de memória para garantir consistência com padrões e ADRs existentes.

3.  **Refinamento** (`/spec-refine`)
    *   Aprimora Specs existentes ou detalha requisitos técnicos adicionais.
    *   Define cenários de borda e estratégias de teste.

4.  **Execução** (`/spec-execute`)
    *   Executa as subtasks já planejadas na fase anterior.
    *   Implementação segue estritamente a Spec e os ACs de cada subtask.

5.  **Revisão & Retrospectiva** (`/spec-review`, `/spec-retro`)
    *   Verifica se a implementação atende a todos os ACs da Spec e das subtasks.
    *   Gera Relatório de Conclusão.
    *   **Consolidação de Memória:** Atualiza o grafo (**Memory MCP**) com aprendizados (LessonLearned) e decisões (ADR).

## Ferramentas MCP Obrigatórias

Para qualquer interação com o Backlog, você **DEVE** utilizar o servidor MCP `backlog`. É estritamente proibido editar arquivos Markdown na pasta `backlog/` ou o arquivo `Backlog.md` manualmente.

As ferramentas disponíveis incluem:
- `backlog_task_create`: Criar novas tarefas (Macro ou Subtasks).
- `backlog_task_list`: Listar tarefas existentes.
- `backlog_task_get`: Ver detalhes de uma tarefa.
- `backlog_task_update`: Atualizar metadados ou marcar como concluída.
- `backlog_task_archive`: Arquivar tarefa.
- `backlog_doc_create`: Criar documentos técnicos ou Specs (usar sempre extensão `.backlog`).
- `backlog_doc_get`: Ler conteúdo de documentos.
- `backlog_doc_list`: Listar documentos disponíveis.
- `backlog_decision_create`: Criar ADRs (Architecture Decision Records).

O servidor MCP é a fonte da verdade e é sincronizado automaticamente com os arquivos Markdown.

## Referências Detalhadas

Para detalhes de cada etapa, o Claude carregará o contexto necessário das referências:
- `spec-init`: Inicialização do projeto e migração de memória.
- `spec-plan`: Planejamento completo (Task, Subtasks e Spec .backlog).
- `spec-execute`: Execução focada em subtasks.
- `spec-refine`: Refinamento de especificações.
- `spec-retro`: Processo de retrospectiva e aprendizado.
