# Relatório de Análise: Spec-Workflow

**Data:** 2026-01-11
**Analisado por:** Gemini-3-Flash-Preview
**Orquestrado por:** Claude Code (Orchestrator)

## 1. Comandos e Referências Analisados
Foram analisados **11 comandos** (`.md` em `commands/`) e **13 arquivos de referência** (`.md` em `references/`).

## 2. Problemas Identificados por Categoria

### A. Inconsistência Crítica de Ferramentas (Tooling Names)
As referências (`references/*.md`) estão utilizando nomes de ferramentas que **não existem** no plugin atual ou estão desatualizados em relação ao servidor MCP do Backlog.
- **Errado (nas referências):** `task_list`, `task_view`, `document_view`, `document_create`, `task_edit`, `task_complete`.
- **Correto (nos comandos):** `backlog_task_list`, `backlog_task_get`, `backlog_doc_get`, `backlog_doc_create`, `backlog_task_update`.

### B. Falta de Ênfase em Subdivisão
Embora o arquivo `spec-next.md` contenha a "Regra de Ouro da Granularidade", o comando principal de execução (`execute.md`) trata a criação de subtarefas como opcional ("SE NECESSÁRIO"). Isso faz com que os agentes tentem resolver tasks gigantes de uma vez, esquecendo argumentos no processo.

### C. Confusão sobre Specs vs. Descrição da Task
Algumas instruções sugerem que a Spec pode estar "dentro da task" ou em "arquivos markdown". O workflow correto exige que a Spec seja um arquivo `.backlog` e a descrição da task seja apenas um resumo sucinto com o link.

### D. Esquecimento de Argumentos em Subagentes
O comando `execute.md` usa um template conceitual para lançar subagentes, mas não reforça que **todo o conteúdo da Spec** e **todos os ACs** devem ser passados integralmente. Se o agente pai resume a spec para o subagente, informações críticas são perdidas.

---

## 3. Análise Detalhada por Arquivo

| Arquivo | Problemas Identificados | Correção Sugerida |
| :--- | :--- | :--- |
| `commands/plan.md` | Não enfatiza que a descrição da task deve ser sucinta. | Adicionar instrução explícita para manter a `description` curta, movendo o detalhamento para o arquivo `.backlog`. |
| `commands/execute.md` | Subdivisão tratada como opcional (Fase 5). | Mudar para "Fase OBRIGATÓRIA de Decomposição" se a task tiver mais de 3 ACs ou afetar > 2 arquivos. |
| `commands/execute.md` | Instrução de subagente (Fase 6) vaga. | Tornar obrigatória a passagem do `spec.content` integral e da lista completa de `acceptance_criteria` para o subagente. |
| `references/spec-execute.md` | Nomes de ferramentas MCP todos errados. | Substituir `task_list` por `backlog_task_list`, `task_view` por `backlog_task_get`, etc. |
| `references/spec-init.md` | Nomes de ferramentas MCP errados. | Substituir `document_create` por `backlog_doc_create`. |
| `references/spec-review.md` | Status da task confuso. | Clarificar que a tarefa DEVE estar em `In Progress` para ser executada e `In Review` para ser revisada. |
| `references/spec-refine.md` | Localização da Spec ambígua. | Reforçar que a Spec **sempre** é um arquivo `.backlog`, nunca apenas texto na task. |
| `references/spec-next.md` | Ferramentas erradas. | Atualizar para os prefixos `backlog_*`. |

---

## 4. Comandos em Conformidade (OK)
Os seguintes arquivos não possuem erros críticos de workflow ou nomenclatura, mas podem ser levemente ajustados para consistência de labels:
- `commands/board.md` ✅ (já corrigido - v2.0.0)
- `commands/search.md`
- `commands/help.md`
- `commands/memorize.md`
- `commands/retro.md` (já possui checklist rigoroso)

---

## 5. Próximos Passos Sugeridos

1. **Unificação de Nomenclatura**: Atualizar todos os arquivos de `references/` para usar os nomes reais das ferramentas MCP (`backlog_task_*`, `backlog_doc_*`).
2. **Reforço de Subdivisão**: Alterar `execute.md` e `spec-next.md` para exigir a quebra de tarefas macro em subtarefas atômicas antes de iniciar o código.
3. **Padrão de Passagem de Contexto**: Atualizar o template de delegação para subagentes em `execute.md` garantindo que nenhum argumento ou detalhe da Spec seja omitido.
4. **Instrução de Status**: Adicionar no `CLAUDE.md` (via `init.md`) que o primeiro ato de qualquer execução é mudar o status da task para `In Progress`.

---

## 6. Priorização de Correções

### 🔴 CRÍTICO (Implementar primeiro)
1. Corrigir nomes de ferramentas MCP em todos os arquivos de referências
2. Tornar subdivisão obrigatória no `execute.md`
3. Reforçar passagem completa de contexto para subagentes

### 🟠 ALTO (Implementar em seguida)
1. Clarificar diferença entre Spec (.backlog) e descrição da task
2. Adicionar instrução de mudança de status para "In Progress"

### 🟡 MÉDIO (Melhorias incrementais)
1. Unificar terminologia em todos os comandos
2. Atualizar exemplos com casos reais do projeto
