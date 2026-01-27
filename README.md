# Linderman's Claude Code Marketplace

Este repositório serve como um **Marketplace de Plugins para Claude Code**, hospedando ferramentas especializadas e skills desenvolvidas para automação, orquestração de IA, engenharia reversa e fluxos de trabalho modernos.

## 📦 Plugins Disponíveis

### `gemini-coordination` (v2.0) ⭐ NOVO
Sistema de orquestração para delegar tarefas aos modelos Gemini (Flash como padrão para implementação, Pro para planejamento complexo) com 8 personas especializadas e protocolo explícito de coleta de contexto.

**Skill incluída:**
- **`gemini-coordination`**: Orquestração multi-modelo com personas especializadas, execução direta via gemini-cli e zero dependências externas.

**Recursos:**
- **8 Personas Especializadas:** frontend-dev, backend-dev, architect, security-expert, database-specialist, test-engineer, devops-engineer, performance-engineer
- **Protocolo de Coleta de Contexto:** 3 fases obrigatórias (leitura, pesquisa, verificação de restrições)
- **Execução Direta:** Via `gemini --approval-mode yolo` sem scripts externos
- **Templates Inline:** Progressive disclosure via `references/prompt-templates.md`
- **Context Verification:** Relatórios incluem "Context Collection Summary"

**Quando usar:**
- Implementar features complexas com agentes Gemini
- Delegar tarefas especializadas (frontend, backend, segurança, etc.)
- Análise de arquitetura e design de sistemas
- Revisão de segurança e performance
- Orquestração multi-fase (Pro planejamento → Flash implementação)

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
# Gemini Coordination (recomendado)
/plugin add gemini-coordination

# PJe Extensions
/plugin add pje-extensions

# Reverse Engineering Utils
/plugin add reverse-engineering-utils

# Git Worktrees
/plugin add git-worktrees
```

### Exemplos de Uso

**Gemini Coordination:**
- "Delegate to gemini: implementar API REST com frontend-dev persona"
- "Use gemini for: análise de segurança com security-expert"
- "Let gemini handle: design de arquitetura com architect persona"

**PJe Extensions:**
- "Como funciona a autenticação do PJe?"
- "Quais os endpoints para listar tarefas?"
- "Como baixar o PDF de um processo via script?"

**Reverse Engineering Utils:**
- "Analisar tráfego de rede da aplicação X"
- "Deofuscar JavaScript do site Y"
- "Automatizar coleta de HAR com Playwright"

**Git Worktrees:**
- "Criar worktree para feature branch X"
- "Gerenciar symlinks de dependências"

## 📚 Estrutura do Repositório

```
linderman-cc-utils/
├── .claude-plugin/
│   └── marketplace.json          # Manifesto do Marketplace
├── plugins/
│   ├── gemini-coordination/      # v2.0 - Orquestração Gemini
│   │   └── skills/
│   │       └── gemini-coordination/
│   │       ├── SKILL.md
│   │       ├── examples/         # Exemplos práticos com personas
│   │       └── references/       # Persona library, templates, guias
│   ├── pje-extensions/           # v0.1 - Extensões Chrome PJe
│   │   └── skills/
│   │       └── pje-reverse-engineering/
│   ├── reverse-engineering-utils/ # v0.1 - Engenharia reversa
│   │   └── skills/
│   │       └── web-traffic-analysis/
│   └── git-worktrees/            # v1.0 - Gerenciamento de worktrees
│       └── skills/
│           └── git-worktrees/
└── README.md
```

## 🎯 Destaques

### gemini-coordination v2.0

**Principais funcionalidades:**
- ✅ **8 personas especializadas** por domínio de expertise
- ✅ **Protocolo de coleta de contexto** (3 fases obrigatórias)
- ✅ **Zero dependências externas** (sem scripts, sem templates)
- ✅ **Execução direta** via `gemini-cli --approval-mode yolo`
- ✅ **Progressive disclosure** (templates em references/)
- ✅ **Context verification** nos relatórios

**Diferencial em relação a outras soluções:**
- Mais simples e direto que gemini-orchestrator (removido)
- Sem scripts externos problemáticos
- Sem templates em arquivos separados
- Coleta de contexto explícita e obrigatória
- Personas especializadas por domínio

## 🤝 Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir PRs com:
- Novas personas para o gemini-coordination
- Novas referências técnicas para PJe ou engenharia reversa
- Melhorias na documentação
- Correção de bugs

## 📝 Changelog

### v2.0 (2026-01-27)
- **ADICIONADO:** gemini-coordination v2.0 com 8 personas e protocolo de contexto
- **REMOVIDO:** spec-workflow (não estava sendo utilizado)
- **REMOVIDO:** gemini-orchestrator (substituído por gemini-coordination)
- **ATUALIZADO:** Marketplace limpo com 4 plugins ativos

### v1.0 (2026-01-23)
- Lançamento inicial do marketplace
- Plugins: pje-extensions, reverse-engineering-utils, git-worktrees
- gemini-orchestrator v1.0

---

Desenvolvido por [Linderman](https://github.com/lindermanqms)
