---
name: spec-execute
description: Guia a execução de uma task planejada, lendo sua Spec e coordenando a implementação. Use este comando para iniciar o trabalho em uma task específica ou para retomar o trabalho na task atual em progresso.
version: 0.2.0
category: workflow
triggers:
  - "/spec-execute"
  - "executar task"
  - "iniciar implementação"
  - "implementar feature"
arguments:
  - name: task_id
    description: ID da task a ser executada (ex: task-1). Se omitido, o agente buscará a tarefa com status 'inprogress'.
    required: false
---

# Executar Task: {{task_id}}

Você está iniciando a fase de **Execução** guiada pelo MCP.

## Procedimento de Execução OBRIGATÓRIO

### 1. Localização da Tarefa
1.  **Buscar Tarefa**: Se `task_id` for fornecido, use `task_view(taskId: "{{task_id}}")`.
2.  **Auto-seleção**: Se `task_id` NÃO for fornecido, use `task_list(status: "inprogress")`.
    - Se houver uma tarefa `inprogress`, assuma-a como foco.
    - Se não houver, use `task_list(status: "todo")`, apresente as opções ao usuário e peça para ele escolher ou inicie a de maior prioridade.

### 2. Leitura da Especificação (Spec)
1.  **Identificar Contexto**: Na descrição ou metadados da tarefa, identifique o documento de Spec (ex: `SPEC-001`).
2.  **Ler Spec**: Use `document_view` para ler o conteúdo da especificação técnica completa.
    - *A Spec é a fonte da verdade.* Nenhuma implementação deve divergir do que foi especificado sem uma atualização prévia no documento.

### 3. Implementação e Subagentes
1.  **Escolha do Especialista**: Dependendo da tecnologia (Python, TS, etc.), utilize o subagente especializado (ex: `python-pro`).
2.  **Instrução ao Agente**: O subagente deve receber a descrição da tarefa e o conteúdo da Spec.
3.  **Gestão de Subtasks**: Se a implementação for complexa, use `task_create` para criar subtarefas técnicas ligadas à principal.

### 4. Ciclo de Atualização
- **Início**: Use `task_edit` para mudar o status para `inprogress` se ainda não estiver.
- **Conclusão**: Após implementar e testar, use `task_complete` para finalizar a tarefa.
- **Histórico**: A tarefa será automaticamente movida para o diretório de histórico pelo servidor MCP.

## Regras de Ouro
- **MCP-Only**: É proibido editar arquivos Markdown de tarefas manualmente. Use as ferramentas.
- **Fidelidade à Spec**: Se os Critérios de Aceite (ACs) não forem atendidos, a tarefa não pode ser completada.
- **Memória**: Ao finalizar, considere usar `/spec-memorize` para registrar aprendizados técnicos no Memory MCP.
