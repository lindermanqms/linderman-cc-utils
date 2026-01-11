# Changelog - Gemini Orchestrator Plugin

## [2.2.4] - 2026-01-11

### Changed
- **SKILL.md**: Adicionado reforço MÁXIMO do GOLDEN RULE
  - Nova seção proeminente no topo: "🚨 GOLDEN RULE - NEVER BREAK THIS 🚨"
  - Adicionado RULE #0 nas Basic Rules (antes de todas as outras)
  - Reorganizada seção Critical Reminders para começar com GOLDEN RULE
  - Lista completa de ações proibidas (NEVER use Edit/Write for code)
  - Única exceção explícita: quando usuário diz "you write the code" ou "don't delegate"

### Rationale

**Motivação**: Reforçar a regra mais importante do plugin - o Orchestrator NUNCA deve escrever código diretamente.

**Problema anterior**:
- Regra existia mas não era suficientemente enfatizada
- Orchestrator poderia confundir quando implementar vs quando delegar
- Faltava clareza sobre a exceção (somente se usuário pedir explicitamente)

**Solução aplicada**:
- GOLDEN RULE agora aparece em 3 locais estratégicos do SKILL.md
- Seção dedicada no início do documento (linhas 22-38)
- RULE #0 nas Basic Rules (linhas 262-276)
- Critical Reminders reorganizado para começar com este aviso (linhas 474-493)

**Impacto esperado**:
- ✅ Orchestrator nunca confunde quando delegar vs implementar
- ✅ Fluxo padrão sempre usa delegate.sh para codificação
- ✅ Exceção clara quando usuário quer implementação direta

### Compatibility

- **Backward Compatibility**: ✅ Sem breaking changes (apenas documentação)
- **Behavioral Compatibility**: ✅ Reforça comportamento desejado existente
- **User Impact**: ✅ Positivo - comportamento mais previsível e consistente

---

## [2.2.3] - 2026-01-11

### Fixed
- **Critical bug in delegate.sh**: Corrigida flag de aprovação automática
  - Antes: `--yolo` (sintaxe incorreta, não existe)
  - Depois: `--approval-mode yolo` (sintaxe correta do gemini-cli)
  - Linha afetada: 223 do delegate.sh
  - Impacto: Script não funcionava, retornava erro "Unknown option: --yolo"

### Changed
- **SKILL.md**: Atualizada nota sobre approval mode
  - De: "Script automatically adds --yolo flag"
  - Para: "Script automatically adds --approval-mode yolo"

### Rationale

**Bug descoberto**: O script delegate.sh usava `--yolo` que não é uma flag válida do gemini-cli.

**Sintaxe correta do gemini-cli**:
- ❌ `gemini -p "..." --yolo` (não existe)
- ✅ `gemini -p "..." --approval-mode yolo` (correto)

**Impacto antes da correção**:
- Todas as delegações via delegate.sh falhavam
- Erro: "Unknown option: --yolo"
- Usuários precisavam usar gemini-cli manualmente

**Depois da correção**:
- Script funciona corretamente
- Aprovação automática ativada
- Workflow delegate.sh totalmente funcional

### Compatibility

- **Backward Compatibility**: ⚠️ Breaking fix (script não funcionava antes)
- **Behavioral Compatibility**: ✅ Agora funciona como documentado
- **User Impact**: ✅ Positivo - script finalmente funciona

---

## [2.2.2] - 2026-01-11

### Changed
- **SKILL.md completamente reescrito** para reforçar uso do delegate.sh
  - Seção "Recommended Workflow: delegate.sh Script" logo no início
  - Tabela comparativa: manual vs delegate.sh
  - Regra #1 explícita: "USE delegate.sh script for all delegations"
  - Exemplos práticos mostram APENAS delegate.sh (não mais `gemini -p "..."`)
  - Seção "Critical Reminders" destaca delegate.sh como primeira regra
  - Eliminadas ambiguidades sobre qual método usar

### Improvements
- **Estrutura mais clara** com hierarquia de regras
  - Delegation Rules (1-6)
  - Orchestrator Responsibilities (7-9)
  - Memory Integration Rules (10-13)
- **Ênfase visual** em responsabilidades:
  - "YOU do this, not agent" em instruções
  - "YOU validate", "YOU manage Backlog"
- **Workflow step-by-step** extremamente detalhado
  - 6 passos numerados para delegação simples
  - 3 fases numeradas para orquestração complexa
- **Seção "Why Use delegate.sh?"** com tabela comparativa
  - 7 aspectos comparados
  - Deixa claro que delegate.sh é superior

### Rationale

**Problema**: SKILL.md anterior tinha ambiguidade sobre método de delegação:
- Mostrava tanto `gemini -p "..."` quanto delegate.sh
- Não ficava claro qual era o método recomendado
- Usuários podiam confundir e usar método manual

**Solução**: Reescrita completa com foco absoluto em delegate.sh:
- delegate.sh mencionado logo na primeira seção
- TODOS os exemplos usam delegate.sh
- Método manual completamente removido dos exemplos
- Regra #1 explícita: USE delegate.sh

### Impact

**Antes**:
- Ambiguidade entre métodos
- Exemplos misturavam abordagens
- Não ficava claro o workflow recomendado

**Depois**:
- Zero ambiguidade: delegate.sh é THE way
- Todos os exemplos consistentes
- Workflow cristalino em 6 passos
- Tabela mostra vantagens do delegate.sh

### Files Modified
- `skills/gemini-orchestrator/SKILL.md` - Reescrita completa (450 linhas)

### Compatibility

- **Backward Compatibility**: ✅ Compatível (apenas documentação)
- **Behavioral Compatibility**: ✅ Nenhuma mudança funcional
- **Documentation Clarity**: ✅ Drasticamente melhorada

---

## [2.2.1] - 2026-01-11

### Changed
- **Clarificação de responsabilidades entre Agents e Orchestrator**
  - Agents Gemini **PODEM** rodar comandos/servidores durante desenvolvimento
  - Agents Gemini **NÃO PODEM** fazer validação final (build, tests, servers)
  - Agents Gemini **NÃO PODEM** usar Backlog.md MCP
  - **Orchestrator (Sonnet)** é exclusivamente responsável por:
    - Validação final (compilation, build, tests)
    - Rodar servidores para validação
    - Todos os usos de Backlog.md MCP (ler tasks, atualizar, marcar ACs)
    - Operações de projeto management

### Updated Files
- **delegation-strategy.md**
  - Matriz expandida com coluna "Can Use Backlog MCP"
  - Seção "When to Act Directly" expandida com Backlog.md e builds
  - Seção "Operation Boundaries" com limitações de validação e MCP
- **SKILL.md**
  - Regra 5 expandida: validação final é responsabilidade do Orchestrator
  - Nova regra 6: Backlog.md MCP é exclusivo do Orchestrator
  - Nova regra 7: Agents podem rodar durante dev, mas validação é do Orchestrator
- **TEMPLATE-flash-implementation.txt**
  - Seção "Development vs Validation" adicionada
  - Limitações de Backlog.md MCP documentadas
  - Limitações de validação final documentadas

### Rationale

**Problema**: Agents Gemini não devem fazer validação final nem usar Backlog.md porque:
1. **Validação final** requer contexto completo da orquestração
2. **Backlog.md** requer entendimento do workflow e estado do projeto
3. **Orchestrator** tem visão completa e pode tomar decisões informadas

**Separação clara**:
- **Durante desenvolvimento** (Agents): npm install, dev server, criar arquivos, etc.
- **Validação final** (Orchestrator): npm run build, npm test, start app for validation
- **Project management** (Orchestrator): TODAS as operações do Backlog.md MCP

### Compatibility

- **Backward Compatibility**: ✅ Compatível (clarificação, não mudança funcional)
- **Behavioral Compatibility**: ✅ Agents continuam podendo rodar comandos durante dev
- **New Constraint**: ⚠️ Backlog.md MCP agora é explicitamente proibido para agents

---

## [2.2.0] - 2026-01-11

### Added
- **Script `delegate.sh`** para execução padronizada de delegações
  - Lê prompts de arquivos (evita problemas de parsing multiline)
  - Auto-detecta modelo (Pro vs Flash) baseado em keywords
  - Salva relatórios automaticamente em `.gemini-orchestration/reports/`
  - Extrai relatórios estruturados usando `extract-report.sh`
  - Nomenclatura padronizada: `{model}-{timestamp}.md`
  - Output completo salvo em `*-full.log` para debugging
- **Estrutura `.gemini-orchestration/`** na raiz do projeto
  - `prompts/` - Arquivos de prompt (.txt)
  - `reports/` - Relatórios gerados (.md, .log)
  - Templates: `TEMPLATE-pro-planning.txt`, `TEMPLATE-flash-implementation.txt`
  - README.md com workflow completo
- **`.gitignore`** atualizado para ignorar `.gemini-orchestration/`

### Novos Componentes

**Script**: `scripts/delegate.sh`
- Opções: `-m|--model` (pro|flash), `-o|--output`, `-f|--format`, `-s|--save-prompt`, `-h|--help`
- Auto-detection de modelo via keywords no prompt
- Geração automática de filename com timestamp
- Tratamento de erros com logs salvos
- Preview de relatório no terminal
- Salvamento de full output para debugging

**Templates**:
- `TEMPLATE-pro-planning.txt` - Template para gemini-3-pro (7 seções)
- `TEMPLATE-flash-implementation.txt` - Template para gemini-3-flash (6 seções)

**Documentação**:
- `.gemini-orchestration/README.md` - Guia completo do workflow
- `references/delegate-script-workflow.md` - Referência técnica

### Changed
- **SKILL.md** - Adicionada seção sobre `delegate-script-workflow.md`
- **README.md** - Adicionada seção "Scripts de Apoio"

### Motivo das Mudanças

**Problema resolvido**: Prompts complexos com múltiplas linhas quebravam quando executados diretamente via `gemini -p "..."` no Bash.

**Erro típico**:
```bash
gemini -p "
  # TAREFA: Implementar X
  ...
" --model gemini-3-flash-preview
# (eval):1: parse error near `()'
```

**Solução**: `delegate.sh` lê prompts de arquivos, evitando problemas de parsing, e padroniza workflow.

### Vantagens do Novo Workflow

| Aspecto | Antes (manual) | Depois (delegate.sh) |
|---------|----------------|---------------------|
| Parsing | ❌ Quebra multiline | ✅ Funciona perfeitamente |
| Salvamento | ❌ Manual | ✅ Automático |
| Extração report | ❌ Manual | ✅ Automática |
| Nomenclatura | ❌ Inconsistente | ✅ Padronizada |
| Histórico | ❌ Difícil rastrear | ✅ Organizado |
| Reutilização | ❌ Prompts perdidos | ✅ Prompts salvos |
| Debugging | ❌ Output perdido | ✅ Full log salvo |

### Usage Examples

**Workflow básico**:
```bash
# 1. Criar prompt baseado em template
cp .gemini-orchestration/prompts/TEMPLATE-flash-implementation.txt \
   .gemini-orchestration/prompts/task-10.txt

# 2. Editar prompt (preencher contexto, ACs, etc.)
vim .gemini-orchestration/prompts/task-10.txt

# 3. Executar delegação (auto-detecta modelo)
./plugins/gemini-orchestrator/scripts/delegate.sh \
  .gemini-orchestration/prompts/task-10.txt

# 4. Revisar relatório
cat .gemini-orchestration/reports/flash-2026-01-11-15-30.md
```

**Delegação complexa (Pro → Flash)**:
```bash
# Design (Pro)
./plugins/gemini-orchestrator/scripts/delegate.sh -m pro \
  .gemini-orchestration/prompts/design-api.txt

# Implementação (Flash) - usar output do Pro
./plugins/gemini-orchestrator/scripts/delegate.sh -m flash \
  .gemini-orchestration/prompts/implement-api.txt
```

**Salvar prompt temporário**:
```bash
./plugins/gemini-orchestrator/scripts/delegate.sh -s /tmp/quick-prompt.txt
```

### Compatibility

- **Backward Compatibility**: ✅ Compatível (adição de scripts)
- **Behavioral Compatibility**: ✅ Workflow manual continua funcionando
- **New Workflow**: ✅ Recomendado para todos os novos usos

### Technical Details

**Arquivos criados**: 6
- 1 script: `scripts/delegate.sh`
- 2 templates: `TEMPLATE-pro-planning.txt`, `TEMPLATE-flash-implementation.txt`
- 3 documentações: `.gemini-orchestration/README.md`, `references/delegate-script-workflow.md`, `.gitignore`

**Diretórios criados**: 1
- `.gemini-orchestration/` (com `prompts/` e `reports/` subdirs)

**Linhas de código**:
- `delegate.sh`: ~350 linhas
- Templates: ~200 linhas (combinados)
- Documentação: ~600 linhas
- Total: ~1,150 linhas

---

## [2.1.1] - 2026-01-11

### Added
- **Flag `--yolo`** em todos os templates de prompt para autonomia completa
  - Agents podem editar/criar arquivos sem confirmação
  - Agents podem executar comandos Bash sem aprovação
  - Agents podem usar MCP servers sem prompts
- **Checagem estática obrigatória** para gemini-3-flash-preview
  - Antes de entregar relatório, deve rodar: lint, typecheck, clippy, etc.
  - Nova seção "Static Analysis Results" no relatório do Flash
- **Protocolo de erro (3 tentativas)** para falhas na checagem estática
  - Attempt 1: Auto-fix (e.g., `npm run lint -- --fix`)
  - Attempt 2: Analisar e corrigir erros específicos
  - Attempt 3: Documentar dificuldades no relatório
- **Limitações de operações destrutivas** para agents Gemini
  - Agents NÃO podem deletar arquivos
  - Agents NÃO podem remover pacotes/dependências
  - Operações destrutivas são responsabilidade do Orchestrator (Sonnet)

### Novos Componentes

**Reference**: `references/cli-configuration.md`
- Guia completo de configuração do gemini-cli
- Flags de aprovação: `--yolo`, `--approval-mode`
- Allowlists de ferramentas via `--allowed-tools`
- Configuração de MCP servers com `trust: true`
- Matriz de capacidades por modelo
- Boas práticas e troubleshooting

### Changed
- **references/prompt-templates.md**
  - Todos os comandos `gemini` agora incluem `--yolo`
  - Template do Flash adicionou "MANDATORY PRE-REPORT REQUIREMENTS"
  - Template do Flash adiciona seção "Static Analysis Results"
  - Template do Flash adiciona lembrete de limitações destrutivas
- **references/delegation-strategy.md**
  - Matriz de responsabilidades expandida com coluna "Can Delete"
  - Seção "Mandatory Protocol: Static Code Analysis" adicionada
  - Seção "Operation Boundaries" documentando operações proibidas
  - Seção "Error Handling Protocol" com 3 tentativas
- **SKILL.md**
  - Versão: 2.0.0 → 2.1.0
  - Adicionada referência a `cli-configuration.md`
  - Exemplo simples atualizado com `--yolo`

### Protocolos Implementados

**Checagem Estática Obrigatória**:
```bash
# TypeScript/JavaScript
npm run lint && npm run typecheck

# Python
ruff check . && mypy .

# Rust
cargo clippy && cargo fmt --check

# Go
go vet ./... && gofmt -l .
```

**Protocolo de Erro (3 tentativas)**:
1. Tentar auto-fix
2. Analisar e corrigir erros específicos
3. Documentar no relatório se não resolver

**Limitações de Operações**:
- ❌ Agents Gemini NÃO podem: deletar arquivos, remover pacotes, rollback migrations, drop tables, modificar git history
- ✅ Orchestrator (Sonnet) PODE: todas as operações acima após análise cuidadosa

### Motivo das Mudanças

1. **Autonomia Completa**: `--yolo` permite operação autônoma sem prompts interativos
2. **Qualidade de Código**: Checagem estática obrigatória garante código de qualidade
3. **Resiliência**: Protocolo de 3 tentativas evita falhas catastróficas
4. **Segurança**: Operações destrutivas requerem aprovação do Orchestrator

### Compatibility

- **Backward Compatibility**: ✅ Compatível (adições de flags e protocolos)
- **Behavioral Compatibility**: ⚠️ Agents agora mais autônomos (requer confiança)
- **Prompt Templates**: ✅ Atualizados para incluir `--yolo`
- **Protocolos**: ✅ Novos protocolos aplicam automaticamente

### Usage Examples

**Comando típico do Flash**:
```bash
gemini -p "Implement feature X" --model gemini-3-flash-preview --yolo
```

**Workflow completo com checagem estática**:
```bash
# Flash implementa com autonomia
gemini -p "Implement auth system" --model gemini-3-flash-preview --yolo

# Flash automaticamente:
# 1. Escreve código
# 2. Roda: npm run lint && npm run typecheck
# 3. Se falhar: auto-fix (attempt 1)
# 4. Se ainda falhar: analisa e fixa (attempt 2)
# 5. Se ainda falhar: documenta no report (attempt 3)
# 6. Entrega relatório com seção "Static Analysis Results"
```

---

## [2.1.0] - 2026-01-11

### Added
- **Sistema de Relatórios Finais Obrigatórios** para todas as delegações
  - Relatórios estruturados com marcadores convencionados para extração fácil
  - Formatos diferentes para Pro (7 seções) vs Flash (6 seções)
  - Script `extract-report.sh` para extração automática de relatórios

### Novos Componentes

**Script**: `scripts/extract-report.sh`
- Extrai relatórios da saída do gemini-cli usando marcadores `=== ORCHESTRATOR REPORT ===`
- Suporta múltiplos formatos: plain (padrão), markdown, json
- Lê de stdin ou arquivo, salva em arquivo ou stdout
- Valida se relatório existe e não está vazio
- Opções: `-o FILE` (output), `-f FORMAT` (format), `-h` (help)

**Seções de Relatório**:

Para **gemini-3-pro** (Planejamento/Análise):
1. Analysis - Análise detalhada do problema/domínio
2. Decisions - Decisões tomadas com justificativa
3. Trade-offs - Trade-offs analisados com prós e contras
4. Alternatives Considered - Alternativas avaliadas e por que foram rejeitadas
5. Risks & Mitigations - Riscos identificados e estratégias de mitigação
6. Recommendations - Recomendações específicas
7. Next Steps - Próximos passos para implementação

Para **gemini-3-flash** (Implementação):
1. Implementation Summary - Resumo conciso do que foi implementado
2. Files Modified - Lista de arquivos criados/modificados
3. Changes Made - Descrição das mudanças em cada arquivo/componente
4. Testing Performed - Testes executados e resultados
5. Results - Achievements (ACs atendidos, testes passando)
6. Issues Found - Problemas encontrados (se houver)

### Changed
- **SKILL.md** - Adicionada seção "Final Reports" com formato e exemplos de uso
- **references/prompt-templates.md** - Templates atualizados com "CRITICAL: YOUR RESPONSE MUST END WITH AN ORCHESTRATOR REPORT"
- **references/workflow-patterns.md** - Todos os exemplos agora incluem extração de relatório após cada delegação

### Usage Examples

**Extração simples**:
```bash
gemini -p "..." --model gemini-3-pro-preview | ./plugins/gemini-orchestrator/scripts/extract-report.sh
```

**Salvar em arquivo**:
```bash
gemini -p "..." --model gemini-3-flash-preview | ./scripts/extract-report.sh -o report.md
```

**Formatar como markdown**:
```bash
gemini -p "..." | ./scripts/extract-report.sh -f markdown > report.md
```

**JSON output**:
```bash
gemini -p "..." | ./scripts/extract-report.sh -f json
```

### Motivo da Mudança

Relatórios estruturados permitem:
- ✅ **Rastreamento**: Histórico completo do que foi feito em cada delegação
- ✅ **Auditoria**: Registros detalhados de decisões e trade-offs
- ✅ **Aprendizado**: Documentação automática de padrões e soluções
- ✅ **Compartilhamento**: Fácil compartilhar resultados com equipe
- ✅ **Integração**: Script standalone pode ser integrado em outros workflows

### Compatibility

- **Backward Compatibility**: ✅ Compatível (adição, não breaking change)
- **Behavioral Compatibility**: ✅ Funcionamento idêntico + relatórios extras
- **Prompt Templates**: ✅ Atualizados para exigir relatórios (mandatory)
- **Workflows**: ✅ Atualizados para extrair relatórios automaticamente

---

## [2.0.0] - 2026-01-11

### BREAKING CHANGES
- **Transformado de agent para skill** com progressive disclosure
  - Agent `/agents/gemini-orchestrator.md` removido
  - Skill `gemini-delegate` renomeada para `gemini-orchestrator`
  - Estrutura alterada de agent para SKILL.md + references/
  - O próprio Claude Code agora é o orquestrador (não um subagente)

### Motivo da Transformação

A mudança de agent para skill oferece vantagens significativas:

- ✅ **Progressive Disclosure**: SKILL.md conciso (~600 palavras), detalhes sob demanda em references/
- ✅ **Performance**: Menor overhead - sem spawning de subagentes
- ✅ **Manutenção**: Mais fácil atualizar partes específicas (cada reference é independente)
- ✅ **Consistência**: Segue o mesmo pattern dos outros plugins (pje-extensions, reverse-engineering-utils)
- ✅ **Descoberta**: Usuários encontram informações específicas mais facilmente

### Added
- **SKILL.md principal** com visão geral concisa
- **9 arquivos de referência detalhados** (references/):
  - `delegation-strategy.md` - Quando usar cada modelo Gemini
  - `context-provision.md` - Como fornecer contexto completo
  - `memory-integration.md` - Integração com Basic Memory
  - `prompt-templates.md` - Templates prontos para uso
  - `workflow-patterns.md` - Padrões de orquestração
  - `error-resolution.md` - Estratégias de resolução de erros
  - `spec-workflow-integration.md` - Integração com Backlog.md
  - `troubleshooting.md` - Solução de problemas
  - `responsibility-matrix.md` - Matriz de responsabilidades
- **README.md simplificado** - Focado em overview e guias rápidos
- **Links funcionais** - Referências cruzadas entre SKILL.md e references/

### Removed
- **Agent definition** (`/agents/gemini-orchestrator.md`)
  - 815 linhas de instruções do agent
- **Skill antiga** (`skills/gemini-delegate/`)
  - Substituída por `skills/gemini-orchestrator/`

### Changed
- **Plugin manifest** (`.claude-plugin/plugin.json`)
  - Version: 1.0.0 → 2.0.0
  - Description: Mantida (já mencionava skill)
  - Skills path: Mantida (`./skills/`)
- **Frontmatter da SKILL.md**
  - `version`: 1.0.0 → 2.0.0
  - `name`: `gemini-orchestrator` (mantido)
  - `description`: Atualizada para refletir skill (não agent)
  - `tools`: Removido (skills não especificam tools)
  - `color`: Removido (skills não usam cores)
- **README.md**
  - De 320 linhas → 148 linhas (53% redução)
  - Foco em overview conciso e guias rápidos
  - Links para documentação detalhada em references/
- **CLAUDE.md** (será atualizado separadamente)
  - Seção "Gemini Orchestrator Plugin" será atualizada de agent para skill

### Migration Notes

#### Para Usuários do Plugin

**Comportamento idêntico**:
- Triggers continuam os mesmos: "delegate to gemini", "use gemini for", etc.
- Funcionalidade preservada: todas as capabilities do agent foram mantidas
- Melhor organização: conteúdo agora é mais fácil de navegar e encontrar

**O que muda**:
- Em vez de invocar um subagente, Claude Code entra em "modo de orquestração"
- A skill é carregada diretamente (mais rápido que spawning de subagente)
- Documentação técnica carregada sob demanda (menor overhead inicial)

**Nenhuma ação necessária**:
- Plugin continua funcionando como antes
- Instalação e pré-requisitos inalterados
- Integração com Basic Memory mantida

#### Para Desenvolvedores

**Estrutura de arquivos**:
```
Antes (v1.0.0):
/agents/gemini-orchestrator.md (815 linhas)
plugins/gemini-orchestrator/skills/gemini-delegate/SKILL.md

Depois (v2.0.0):
plugins/gemini-orchestrator/skills/gemini-orchestrator/SKILL.md
plugins/gemini-orchestrator/skills/gemini-orchestrator/references/*.md (9 arquivos)
```

**Conteúdo redistribuído**:
- Todo o conteúdo do agent foi preservado
- Conteúdo principal → SKILL.md
- Conteúdo detalhado → 9 arquivos references/
- Total: ~815 linhas → distribuídas em 10 arquivos

### Compatibility

- **Backward Compatibility**: ❌ Breaking change na arquitetura (agent → skill)
- **Functional Compatibility**: ✅ Comportamento idêntico para usuário final
- **Trigger Compatibility**: ✅ Mesmas frases ativam a skill
- **Memory Compatibility**: ✅ Entidades mantêm mesma estrutura (prefixação mantida)
- **Integration Compatibility**: ✅ Integração com spec-workflow preservada

### Technical Details

**Arquivos criados**: 11
- 1 SKILL.md
- 9 references/*.md
- 1 README.md (simplificado)

**Arquivos modificados**: 2
- .claude-plugin/plugin.json (version bump)
- CHANGELOG.md (este arquivo)

**Arquivos removidos**: 2
- /agents/gemini-orchestrator.md
- /plugins/gemini-orchestrator/skills/gemini-delegate/

**Linhas de código**:
- Agent original: 815 linhas em 1 arquivo
- Skill v2.0: ~3,500 linhas em 10 arquivos
- SKILL.md: ~500 linhas (visão geral)
- References: ~3,000 linhas (detalhes técnicos)

### Benefícios da Transformação

1. **Performance**: Skill carrega instantaneamente vs spawning de subagente
2. **Descoberta**: Usuário encontra informações específicas mais facilmente
3. **Manutenção**: Atualizar um reference não afeta outros
4. **Escalabilidade**: Fácil adicionar novos references no futuro
5. **Consistência**: Alinhado com padrões do marketplace (pje-extensions, reverse-engineering-utils)

### Future Enhancements

Com a nova estrutura, futuras melhorias são mais fáceis:

- Adicionar novos references sem tocar na SKILL.md
- Traduzir SKILL.md para outros idiomas mantendo references técnicos
- Adicionar examples/ com casos de uso completos
- Criar references específicos por domínio (ex: web-development, mobile, data)

---

## [1.0.0] - 2026-01-11

### Added
- **Agent**: `gemini-orchestrator` com 815 linhas de instruções
- **Skill**: `gemini-delegate` como gateway para o agent
- **Integração**: Basic Memory MCP para auto-fetch e auto-save
- **Workflows**: 3 padrões (Simple, Complex, Error Resolution)
- **Documentação**: README.md e CHANGELOG.md completos

### Features
- Delegação inteligente (Pro para planning, Flash para implementation)
- Coleta automática de contexto (CLAUDE.md, specs, código existente)
- Integração com spec-workflow (ler ACs, atualizar tasks)
- Matriz de responsabilidades detalhada
- Templates de prompt prontos para uso
- Tratamento de erros com retry e diagnóstico

### Initial Release
- Primeira versão como agent
- Marketplace `linderman-cc-utils` configurado
- Pré-requisitos: gemini-cli, API key, Basic Memory MCP opcional
