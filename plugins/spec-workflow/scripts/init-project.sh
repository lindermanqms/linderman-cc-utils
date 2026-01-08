#!/bin/bash

# 1. Garante instalação
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
bash "$DIR/ensure-backlog.sh"

# 2. Inicializa o projeto Backlog se necessário
if [ ! -d "backlog" ] || [ ! -f "Backlog.md" ]; then
    echo "Inicializando projeto Backlog.md..."
    # --defaults usa valores padrão
    # --integration-mode mcp ativa as ferramentas MCP
    # --agent-instructions agents cria o AGENTS.md
    # --install-claude-agent false evita instalar o agente padrão do backlog (pois temos o spec-workflow)
    backlog init --defaults --integration-mode mcp --agent-instructions agents --install-claude-agent false
fi

# 3. Sobrescreve Backlog.md com o template obrigatório
cat << 'EOF' > Backlog.md
# Backlog

## 📦 Specs
<!--
As Specs são documentos vivos que descrevem features, melhorias ou correções antes de qualquer código ser escrito.
Elas seguem o padrão SPEC-{ID}: {Nome da Feature}.
-->

## 🏛️ Constituição do Projeto
<!--
A Constituição define as regras inegociáveis do projeto, padrões de código, arquitetura e convenções que devem ser seguidas.
-->
EOF

# 4. Garante estrutura de pastas para specs e docs (usado pelo spec-workflow)
mkdir -p backlog/specs
mkdir -p backlog/docs

echo "Projeto inicializado com sucesso com integração MCP!"
