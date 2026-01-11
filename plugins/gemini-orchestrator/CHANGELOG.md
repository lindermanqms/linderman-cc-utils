# Changelog - Gemini Orchestrator Plugin

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
