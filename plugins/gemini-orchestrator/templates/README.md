# Gemini Orchestrator Templates

Este diretório contém templates de prompts para delegações aos modelos Gemini.

## Templates Disponíveis

- **TEMPLATE-pro-planning.txt** - Para delegações ao gemini-3-pro-preview (planejamento, design, análise)
- **TEMPLATE-flash-implementation.txt** - Para delegações ao gemini-3-flash-preview (implementação, codificação)
- **SETUP-GUIDE.md** - Guia completo de setup e workflow (copiar para .claude/gemini-orchestrator/README.md)

## Como Usar

### 1. Inicialização (uma vez por projeto)

Quando usar o plugin gemini-orchestrator em um novo projeto, execute:

```bash
# Criar estrutura de diretórios
mkdir -p .claude/gemini-orchestrator/prompts
mkdir -p .claude/gemini-orchestrator/reports

# Copiar templates do plugin para o projeto
cp plugins/gemini-orchestrator/templates/TEMPLATE-*.txt \
   .claude/gemini-orchestrator/prompts/

# Copiar guia de setup para referência fácil
cp plugins/gemini-orchestrator/templates/SETUP-GUIDE.md \
   .claude/gemini-orchestrator/README.md

# Verificar que templates foram copiados
ls -la .claude/gemini-orchestrator/prompts/TEMPLATE-*.txt
ls -la .claude/gemini-orchestrator/README.md
```

### 2. Criar Prompt para Delegação

Para cada tarefa, crie um prompt a partir do template apropriado:

```bash
# Para planejamento/design (Pro)
cp .claude/gemini-orchestrator/prompts/TEMPLATE-pro-planning.txt \
   .claude/gemini-orchestrator/prompts/task-10-design-api.txt

# Para implementação (Flash)
cp .claude/gemini-orchestrator/prompts/TEMPLATE-flash-implementation.txt \
   .claude/gemini-orchestrator/prompts/task-10-implement-api.txt
```

### 3. Editar e Executar

1. Edite o arquivo criado preenchendo todas as seções
2. Execute via delegate.sh: `./plugins/gemini-orchestrator/scripts/delegate.sh .claude/gemini-orchestrator/prompts/task-10-design-api.txt`

## Por Que Templates Ficam no Plugin?

- ✅ **Single source of truth** - Templates atualizados com o plugin
- ✅ **Versionamento** - Templates fazem parte do plugin versionado
- ✅ **Disponibilidade** - Templates sempre disponíveis para novos projetos
- ❌ **`.claude/gemini-orchestrator/` está no .gitignore** - Não seria versionado

## Estrutura Completa

```
projeto/
├── plugins/
│   └── gemini-orchestrator/
│       ├── templates/              ← Templates originais (versionados)
│       │   ├── TEMPLATE-pro-planning.txt
│       │   ├── TEMPLATE-flash-implementation.txt
│       │   └── SETUP-GUIDE.md
│       └── scripts/
│           └── delegate.sh
└── .claude/gemini-orchestrator/          ← Diretório de trabalho (gitignored)
    ├── README.md                   ← Guia de setup (copiado do plugin)
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
