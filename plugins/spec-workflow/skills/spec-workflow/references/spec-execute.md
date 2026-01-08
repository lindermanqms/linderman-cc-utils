# Spec-Driven Execution Knowledge Base

## Filosofia de Execução
No Spec-Driven Development, a execução é um processo de **tradução**, não de invenção. O código é apenas a materialização da Spec. Se a Spec for ruim, o código será ruim.

## O Fluxo de Execução MCP-Only

O comando `/spec-execute` gerencia o ciclo de vida da execução utilizando as ferramentas MCP:

### 1. Seleção de Tarefa
O agente utiliza `task_list` com filtro `status: in_progress` para identificar o trabalho atual. Caso não haja tarefa em progresso, o agente listará as tarefas em `todo` e solicitará ao usuário para escolher uma ou iniciará a de maior prioridade.

### 2. Preparação do Contexto
Após selecionar a tarefa, o agente utiliza:
- `task_view`: Para ler a descrição, critérios de aceite e referências à Spec.
- `document_view`: Caso a tarefa referencie uma Spec (ex: `SPEC-001`), o agente deve ler o documento da Spec para ter o contexto total.

### 3. Implementação e Atualização
Durante a implementação:
- **Subtarefas**: Use `task_create` para quebrar a tarefa principal se necessário.
- **Progresso**: Atualize o status com `task_edit` conforme marcos intermediários são alcançados.
- **Conclusão**: Use `task_complete` para finalizar a tarefa e mover para o arquivo de histórico.

## Ferramentas Relacionadas
- `task_list`: Localizar tarefas.
- `task_view`: Entender o que deve ser feito.
- `document_view`: Ler a especificação (Spec).
- `task_complete`: Finalizar o trabalho.
