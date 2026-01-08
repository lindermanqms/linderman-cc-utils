---
name: spec-replan
description: Reestrutura o backlog em resposta a uma mudança crítica de cenário. Identifica tarefas obsoletas para arquivar, specs que precisam de reescrita e novas lacunas.
version: 0.1.0
category: workflow
triggers:
  - "/spec-replan"
  - "replanch"
  - "mudar plano"
  - "reestruturar backlog"
arguments:
  - name: change-description
    description: Descrição da mudança crítica que motiva o replanejamento
    required: true
---

# Spec-Replan: Reestruturação Estratégica do Backlog

Este comando é utilizado quando o cenário do projeto muda drasticamente (mudança de tecnologia, novos requisitos de negócio, pivot de arquitetura) e o plano atual não é mais válido.

## Workflow de Replanejamento

### Fase 1: Triagem e Análise de Impacto

1. **Entenda a Mudança:** Analise profundamente a descrição fornecida: `{{change-description}}`.
2. **Audit do Backlog:**
   - Use `backlog_task_list` para identificar tarefas em aberto (`todo`, `in_progress`).
   - Identifique quais tarefas são diretamente impactadas pela mudança.
3. **Verificação da Constituição:**
   - Verifique se a mudança conflita com os padrões atuais (arquivos em `docs/standards/` ou `backlog/docs/`).

### Fase 2: Classificação de Sobrevivência

Para cada tarefa impactada, classifique-a em uma destas categorias:

- 🛑 **OBSOLETA (Archive):** A tarefa perdeu o sentido ou foi cancelada.
- ✏️ **MUTANTE (Update):** A tarefa ainda é necessária, mas seus Critérios de Aceite ou Spec precisam de revisão.
- ✨ **LACUNA (New):** O novo cenário exige novas tarefas que não estavam mapeadas.

### Fase 3: Relatório de Cirurgia (Surgery Report)

Apresente um plano de ação para o usuário aprovar:

```markdown
🚨 **Relatório de Impacto: Mudança de Cenário**

**Cenário Atualizado:** {{change-description}}

**1. Documentação (A Constituição)**
- [ ] Sugestão de atualização em `docs/standards/` (se aplicável).
- [ ] Criar ADR/Decisão (via `backlog_decision_create`) registrando o motivo da mudança.

**2. Ações Destrutivas (Limpeza)**
- 🛑 **Arquivar/Cancelar:**
  - `TASK-ID`: [Motivo]

**3. Ações de Modificação (Refinamento)**
- ✏️ **Atualizar/Reescrever Spec:**
  - `TASK-ID`: [O que muda]

**4. Ações Construtivas (Novas Tasks)**
- ✨ **Criar:**
  - `[Título Nova Task]`: [Breve descrição]
```

### Fase 4: Execução do Plano

Após a aprovação do usuário:

1. Use `backlog_task_archive` para as tarefas obsoletas.
2. Use `backlog_task_update` para as tarefas mutantes, registrando o novo contexto no campo `plan`.
3. Use `backlog_task_create` para as novas lacunas identificadas.
4. Use `backlog_decision_create` para registrar formalmente a mudança de rumo.

## Notas Importantes

- **Seja Radical:** Se uma tarefa não agrega mais valor no novo cenário, arquive-a sem hesitação.
- **Transparência:** Sempre registre o "Porquê" da mudança para consulta futura.
- **Consistência:** Garanta que a documentação de padrões acompanhe o novo plano.
