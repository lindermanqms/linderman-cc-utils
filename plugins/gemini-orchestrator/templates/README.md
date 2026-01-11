# Gemini Orchestrator Templates

Este diretório contém templates de prompts para delegações aos modelos Gemini.

## Templates Disponíveis

- **TEMPLATE-pro-planning.txt** - Para delegações ao gemini-3-pro-preview (planejamento, design, análise)
- **TEMPLATE-flash-implementation.txt** - Para delegações ao gemini-3-flash-preview (implementação, codificação)

## Como Usar

### 1. Inicialização (uma vez por projeto)

Quando usar o plugin gemini-orchestrator em um novo projeto, execute:

```bash
# Criar estrutura de diretórios
mkdir -p .gemini-orchestration/prompts
mkdir -p .gemini-orchestration/reports

# Copiar templates do plugin para o projeto
cp plugins/gemini-orchestrator/templates/TEMPLATE-*.txt \
   .gemini-orchestration/prompts/

# Verificar que templates foram copiados
ls -la .gemini-orchestration/prompts/TEMPLATE-*.txt
```

### 2. Criar Prompt para Delegação

Para cada tarefa, crie um prompt a partir do template apropriado:

```bash
# Para planejamento/design (Pro)
cp .gemini-orchestration/prompts/TEMPLATE-pro-planning.txt \
   .gemini-orchestration/prompts/task-10-design-api.txt

# Para implementação (Flash)
cp .gemini-orchestration/prompts/TEMPLATE-flash-implementation.txt \
   .gemini-orchestration/prompts/task-10-implement-api.txt
```

### 3. Editar e Executar

1. Edite o arquivo criado preenchendo todas as seções
2. Execute via delegate.sh: `./plugins/gemini-orchestrator/scripts/delegate.sh .gemini-orchestration/prompts/task-10-design-api.txt`

## Por Que Templates Ficam no Plugin?

- ✅ **Single source of truth** - Templates atualizados com o plugin
- ✅ **Versionamento** - Templates fazem parte do plugin versionado
- ✅ **Disponibilidade** - Templates sempre disponíveis para novos projetos
- ❌ **`.gemini-orchestration/` está no .gitignore** - Não seria versionado

## Estrutura Completa

```
projeto/
├── plugins/
│   └── gemini-orchestrator/
│       ├── templates/              ← Templates originais (versionados)
│       │   ├── TEMPLATE-pro-planning.txt
│       │   └── TEMPLATE-flash-implementation.txt
│       └── scripts/
│           └── delegate.sh
└── .gemini-orchestration/          ← Diretório de trabalho (gitignored)
    ├── prompts/                    ← Cópias dos templates + prompts de tarefas
    │   ├── TEMPLATE-pro-planning.txt (copiado do plugin)
    │   ├── TEMPLATE-flash-implementation.txt (copiado do plugin)
    │   ├── task-10-design-api.txt
    │   └── task-10-implement-api.txt
    └── reports/                    ← Relatórios gerados
        ├── pro-2026-01-11-14-00.md
        └── flash-2026-01-11-15-30.md
```

## Referências

- **SKILL.md completo**: `plugins/gemini-orchestrator/skills/gemini-orchestrator/SKILL.md`
- **Exemplos práticos**: `plugins/gemini-orchestrator/skills/gemini-orchestrator/examples/`
- **Documentação técnica**: `plugins/gemini-orchestrator/skills/gemini-orchestrator/references/`
