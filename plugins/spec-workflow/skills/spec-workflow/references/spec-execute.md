# Spec-Driven Execution Knowledge Base

## Filosofia de Execução
No Spec-Driven Development, a execução é um processo de **tradução**, não de invenção. O código é apenas a materialização da Spec. Se a Spec for ruim, o código será ruim.

## O Fluxo de Execução MCP-Only

O comando `/spec-execute` gerencia o ciclo de vida da execução utilizando as ferramentas MCP:

### 1. Seleção de Tarefa
O agente utiliza `backlog_task_list` com filtro `status: "In Progress"` para identificar o trabalho atual. Caso não haja tarefa em progresso, o agente listará as tarefas com `status: "To Do"` e solicitará ao usuário para escolher uma ou iniciará a de maior prioridade.

### 2. Preparação do Contexto
Após selecionar a tarefa, o agente utiliza:
- `backlog_task_get`: Para ler a descrição, critérios de aceite e referências à Spec.
- `backlog_doc_get`: Caso a tarefa referencie uma Spec (ex: `SPEC-001`), o agente DEVE ler o documento da Spec para ter o contexto total.

### 3. Implementação e Atualização
Durante a implementação:
- **Subtarefas**: Use `backlog_task_create` para quebrar a tarefa principal se necessário.
- **Progresso**: Atualize o status com `backlog_task_update` conforme marcos intermediários são alcançados.
- **Conclusão**: Use `backlog_task_update` com `status: "Done"` para finalizar a tarefa.

## Ferramentas Relacionadas
- `backlog_task_list`: Localizar tarefas.
- `backlog_task_get`: Entender o que deve ser feito.
- `backlog_doc_get`: Ler a especificação (Spec).
- `backlog_task_update`: Atualizar progresso e finalizar o trabalho.
