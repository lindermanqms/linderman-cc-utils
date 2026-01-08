# Memory & Knowledge Graph Hook

Sempre que utilizar ferramentas do **Memory MCP**, garanta a aderência ao **Padrão Estrito do Projeto**.

## Padrão de Entidades
- **Project**: Informações de alto nível.
- **Standard**: Padrões e convenções.
- **ADR**: Decisões arquiteturais importantes.
- **TechStack**: Tecnologias utilizadas.
- **LessonLearned**: Aprendizados de retrospectivas.

## Automação
Ao finalizar um comando `/spec-retro`, este hook deve guiar o subagente de background para:
1. Analisar o histórico da sessão.
2. Identificar novos nós e observações.
3. Executar as ferramentas de criação/atualização no Memory MCP respeitando a tipagem acima.
