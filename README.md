# Linderman's Claude Code Marketplace

Este repositório serve como um **Marketplace de Plugins para Claude Code**, hospedando ferramentas especializadas e skills desenvolvidas para automação e engenharia reversa, com foco principal no ecossistema do **PJe (Processo Judicial Eletrônico)** do TRF5.

## 📦 Plugins Disponíveis

### `pje-extensions`
Ferramentas e skills para desenvolvimento de extensões Chrome e automação do PJe (TRF5).

**Skills incluídos:**
- **`pje-reverse-engineering`**: Base de conhecimento técnica completa sobre a engenharia reversa do PJe.
  - Catálogo de API Endpoints
  - Mecanismos de Autenticação e Sessão
  - Fluxos de Download de Processos (com bypass de ViewState)
  - Automação de Movimentação (Deep Linking)
  - Scraping de Telas JSF/RichFaces

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

### Instalar o plugin PJe Extensions

```bash
/plugin add pje-extensions
```

### Usar o Skill de Engenharia Reversa

Basta perguntar ao Claude sobre aspectos técnicos do PJe. O skill será ativado automaticamente por frases-gatilho.

**Exemplos:**
- *"Como funciona a autenticação do PJe?"*
- *"Quais os endpoints para listar tarefas?"*
- *"Como baixar o PDF de um processo via script?"*
- *"Explique a estrutura da tabela de expedientes."*

## 📚 Estrutura do Repositório

```
linderman-cc-utils/
├── .claude-plugin/
│   └── marketplace.json          # Manifesto do Marketplace
├── plugins/
│   └── pje-extensions/
│       ├── .claude-plugin/       # Manifesto do Plugin
│       └── skills/
│           └── pje-reverse-engineering/
│               ├── SKILL.md      # Definição do Skill
│               └── references/   # Documentação técnica detalhada
└── README.md
```

## 🤝 Contribuição

Contribuições são bem-vindas! Se você descobriu novos endpoints ou comportamentos do PJe, sinta-se à vontade para abrir um PR adicionando novos arquivos à pasta `references/` do skill.

---
Desenvolvido por [Linderman](https://github.com/lindermanqms)
