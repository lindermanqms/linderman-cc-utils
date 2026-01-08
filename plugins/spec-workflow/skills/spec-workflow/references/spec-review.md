---
description: Realiza QA da tarefa antes da conclusão: verifica ACs, analisa código implementado e checa necessidade de atualização da documentação.
arg_name: task-id
---
# Spec QA & Review

1. **Auditoria de ACs**: Liste os ACs da task {{task-id}} (use `backlog_task_get`). Para cada um, busque evidência no código atual de que ele foi cumprido.
2. **Auditoria de Doc**: A implementação alterou algum padrão ou regra de negócio?
   - Se SIM: Liste quais arquivos em `backlog/docs/` devem ser editados.
   - Se NÃO: Confirme explicitamente "Nenhum impacto na documentação".
3. **Limpeza**: Verifique se há TODOs ou comentários temporários deixados no código.
4. **Veredito**:
   - Aprovado: Sugira o uso de `backlog_task_update` para mover o status para "Done".
   - Reprovado: Liste o que falta para fechar os ACs e mantenha em "In Progress" ou mova para "Review" se houver essa coluna.
