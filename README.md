# Linderman's Claude Code Marketplace

Este repositório serve como um **Marketplace de Plugins para Claude Code**, hospedando ferramentas especializadas e skills desenvolvidas para automação, orquestração de IA, engenharia reversa e fluxos de trabalho modernos.

## 📦 Plugins Disponíveis

### `spec-workflow` (v2.0)
Plugin de **Spec-Driven Development** com integração completa ao Backlog.md MCP e Basic Memory.

**Commands incluídos:**
- `/spec-init` - Inicializar ambiente com validação de CLI
- `/spec-plan` - Criar task + spec com todos os campos MCP
- `/spec-execute` - Executar task com gerenciamento de dependências
- `/spec-review` - Revisar com validação automática de ACs
- `/spec-retro` - Finalizar com checklist e Basic Memory
- `/spec-replan` - Reestruturar backlog com análise de impacto
- `/spec-align` - CRUD de documentos de padrões
- `/spec-memorize` - Salvar aprendizados no Basic Memory
- `/spec-board` - Kanban interativo com estatísticas
- `/spec-search` - Busca fuzzy em tasks/specs/docs
- `/spec-help` - Documentação completa

### `gemini-orchestrator` (v2.3)
Sistema de orquestração para delegar tarefas complexas aos modelos Gemini (Pro para planejamento, Flash para implementação).

**Skill incluída:**
- **`gemini-orchestrator`**: Orquestração automática com coleta de contexto, integração com Basic Memory e separação clara de responsabilidades (Orchestrator vs Agents).

**Recursos:**
- Delegação inteligente para gemini-3-pro-preview (planejamento) e gemini-3-flash-preview (implementação)
- Coleta automática de contexto do projeto
- Integração com Basic Memory para salvar padrões, ADRs e resoluções de erros
- Matriz de responsabilidades clara (Orchestrator valida, Agents implementam)

### `pje-extensions` (v0.1)
Ferramentas e skills para desenvolvimento de extensões Chrome e automação do PJe (Processo Judicial Eletrônico - TRF5).

**Skills incluídas:**
- **`pje-reverse-engineering`**: Base de conhecimento técnica completa sobre a engenharia reversa do PJe.
  - Catálogo de API Endpoints
  - Mecanismos de Autenticação e Sessão
  - Fluxos de Download de Processos (com bypass de ViewState)
  - Automação de Movimentação (Deep Linking)
  - Scraping de Telas JSF/RichFaces

### `reverse-engineering-utils` (v0.1)
Ferramentas gerais para engenharia reversa web e análise de tráfego de rede.

**Skills incluídas:**
- **`web-traffic-analysis`**: Técnicas e ferramentas para análise de HAR, deobfuscação de JavaScript, automação com Playwright e análise dinâmica.

### `git-worktrees` (v1.0)
Sistema avançado para gerenciamento de worktrees Git com paralelização de workflows.

**Skills incluídas:**
- **`git-worktrees`**: Guia completo para criação, gerenciamento de symlinks, paralelização de workflows e cleanup strategies.

## 🚀 Instalação

Para usar este marketplace no seu Claude Code, você precisa adicionar este repositório como uma fonte de plugins.

### Pré-requisitos
- [Claude Code](https://claude.ai/code) instalado e autenticado.

### Adicionar o Marketplace

Execute o seguinte comando no seu terminal Claude Code:

```bash
/plugin add marketplace https://github.com/lindermanqms/linderman-cc-utils
```

Ou, se preferir clonar e usar localmente para desenvolvimento:

1. Clone o repositório:
   ```bash
   git clone https://github.com/lindermanqms/linderman-cc-utils.git
   ```

2. Adicione o marketplace localmente (dentro da pasta do projeto):
   ```bash
   /plugin add marketplace .
   ```

## 🛠️ Uso

Após instalar o marketplace, você pode instalar os plugins individuais.

### Instalar Plugins

```bash
# Spec-Driven Development
/plugin add spec-workflow

# Gemini Orchestrator
/plugin add gemini-orchestrator

# PJe Extensions
/plugin add pje-extensions

# Reverse Engineering Utils
/plugin add reverse-engineering-utils

# Git Worktrees
/plugin add git-worktrees
```

### Exemplos de Uso

**Spec-Workflow:**
- `/spec-plan "Implementar autenticação JWT"`
- `/spec-execute task-10`
- `/spec-board --milestone "v1.0"`

**Gemini Orchestrator:**
- "Delegate to gemini: implementar API REST"
- "Use gemini for: refatorar código do módulo X"

**PJe Extensions:**
- "Como funciona a autenticação do PJe?"
- "Quais os endpoints para listar tarefas?"
- "Como baixar o PDF de um processo via script?"

## 📚 Estrutura do Repositório

```
linderman-cc-utils/
├── .claude-plugin/
│   └── marketplace.json          # Manifesto do Marketplace
├── plugins/
│   ├── spec-workflow/
│   │   ├── commands/             # 11 commands /spec-*
│   │   └── skills/
│   │       └── spec-workflow/
│   │           ├── SKILL.md
│   │           └── references/
│   ├── gemini-orchestrator/
│   │   ├── scripts/              # delegate.sh, extract-report.sh
│   │   ├── templates/            # Prompts versionados
│   │   └── skills/
│   │       └── gemini-orchestrator/
│   │           ├── SKILL.md
│   │           └── references/   # 12 referências técnicas
│   ├── pje-extensions/
│   │   └── skills/
│   │       └── pje-reverse-engineering/
│   ├── reverse-engineering-utils/
│   │   └── skills/
│   │       └── web-traffic-analysis/
│   └── git-worktrees/
│       └── skills/
│           └── git-worktrees/
└── README.md
```

## 🤝 Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir PRs com:
- Novos comandos para o spec-workflow
- Templates de prompts para o gemini-orchestrator
- Novas referências técnicas para PJe ou engenharia reversa
- Melhorias na documentação

---
Desenvolvido por [Linderman](https://github.com/lindermanqms)
