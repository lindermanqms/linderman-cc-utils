# CLI Configuration

Guia completo de configuração do gemini-cli para orquestração autônoma.

## Overview

Para que os agentes Gemini operem de forma autônoma no modo headless, é necessário configurar aprovações automáticas e permissões de ferramentas.

## Flags de Aprovação

### `--yolo` (You Only Live Once)

**Uso recomendado**: Orquestração autônoma completa

```bash
gemini -p "..." --model gemini-3-flash-preview --yolo
```

**O que faz**:
- ✅ Aprova automaticamente TODAS as tool calls
- ✅ Permite criar/editar/deletar arquivos sem confirmação
- ✅ Permite executar comandos Bash sem aprovação
- ✅ Permite usar MCP servers sem prompts
- ✅ Ajusta permissões de arquivos quando necessário

**Quando usar**:
- Em workflows de orquestração autônoma (gemini-orchestrator)
- Quando o Orchestrator (Sonnet) supervisiona a execução
- Em ambientes de desenvolvimento controlados
- Quando você confia no contexto fornecido ao agente

**⚠️ Aviso**: Use apenas em ambientes de desenvolvimento ou quando você entende as implicações de execução automática.

### `--approval-mode auto_edit`

**Uso**: Aprova apenas edições de arquivos

```bash
gemini -p "..." --approval-mode auto_edit
```

**O que faz**:
- ✅ Auto-aprova: write_file, replace, edit
- ❌ Ainda pede confirmação para: run_shell_command, ferramentas MCP

**Quando usar**:
- Quando você quer revisar comandos antes da execução
- Para operações de refatoração seguras
- Em ambientes semi-automatizados

### `--approval-mode default` (Default)

**Uso**: Modo interativo padrão

```bash
gemini -p "..." --approval-mode default
```

**O que faz**:
- ❌ Pede confirmação para TODAS as tool calls destrutivas
- Use apenas para testes manuais ou debugging

## Matriz de Capacidades por Modelo

| Capacidade | gemini-3-pro --yolo | gemini-3-flash --yolo |
|------------|---------------------|----------------------|
| Ler arquivos | ✅ | ✅ |
| Criar arquivos | ❌* | ✅ |
| Editar arquivos | ❌* | ✅ |
| Deletar arquivos | ❌* | ✅ |
| Executar Bash | ❌* | ✅ |
| Ajustar permissões | ✅ | ✅ |
| Usar MCP | ❌* | ✅ |
| Rodar scripts dev | ❌* | ✅ |
| Iniciar servers | ❌* | ✅ |

*Pro pode fazer essas ações em teoria, mas **não deve** - sua função é análise e planejamento.

## Allowlist de Ferramentas

### `--allowed-tools`

Restringe ferramentas disponíveis para o agente:

```bash
# Permitir apenas edição de arquivos
gemini -p "..." --allowed-tools "write_file,replace,read_file"

# Permitir edição + shell (mas sem MCP)
gemini -p "..." --allowed-tools "write_file,replace,read_file,run_shell_command"
```

**Quando usar**:
- Para limitar superfície de ataque
- Em workflows específicos que não precisam de todas as ferramentas
- Para debugging de comportamentos

### Via `settings.json`

Configuração persistente em `.gemini/settings.json`:

```json
{
  "tools": {
    "allowed": ["write_file", "replace", "read_file", "run_shell_command"],
    "core": ["read_file", "write_file", "replace"]
  }
}
```

**`tools.core`**: Restringe built-ins disponíveis (subset de tools.allowed)

## Contexto e Diretórios

### `--include-directories`

Inclui diretórios adicionais no workspace do agente:

```bash
# Incluir documentação externa
gemini -p "..." --include-directories "../docs,../shared"

# Incluir múltiplos diretórios
gemini -p "..." --include-directories "./src,./tests,./docs"
```

**Quando usar**:
- Quando a documentação está fora do projeto
- Para compartilhar código entre projetos
- Para incluir assets ou configurações externas

### Via `settings.json`

```json
{
  "context": {
    "includeDirectories": ["../docs", "../shared"]
  }
}
```

## Integração com MCP

### Configuração de Servidores

Em `.gemini/settings.json`:

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "trust": true
    },
    "backlog": {
      "command": "npx",
      "args": ["-y", "backlog-md-mcp"],
      "trust": true
    }
  }
}
```

**`trust: true`**: Bypassa confirmações para este servidor MCP

### Filtrar Tools do MCP

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path"],
      "includeTools": ["read_file", "write_file"],
      "excludeTools": ["delete_file"]
    }
  }
}
```

## Sandbox

### `--sandbox`

Isola execução em ambiente sandbox:

```bash
gemini -p "..." --sandbox
```

**O que faz**:
- Executa ferramentas em ambiente isolado (Docker/Podman/sandbox-exec)
- Reverte mudanças ao final (opcional)
- Protege sistema host

**Limitações**:
- MCP servers devem estar disponíveis DENTRO do sandbox
- Arquivos fora do sandbox não podem ser acessados
- Comandos Bash executam no contexto do sandbox

**Quando usar**:
- Para testar código não confiável
- Em ambientes de CI/CD
- Para prototipagem segura

## Configuração Recomendada para gemini-orchestrator

### Development Mode

```json
{
  "approvalMode": "yolo",
  "tools": {
    "allowed": ["*"]
  },
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "trust": true
    }
  }
}
```

### CI/CD Mode

```json
{
  "approvalMode": "auto_edit",
  "tools": {
    "allowed": ["read_file", "write_file", "replace", "run_shell_command"]
  }
}
```

## Troubleshooting

### Erro: "Tool not allowed"

**Causa**: Ferramenta não está na allowlist

**Solução**:
```bash
# Adicionar à allowlist via CLI
gemini -p "..." --allowed-tools "write_file,replace,run_shell_command"

# Ou configurar em settings.json
```

### Erro: "Confirmation required"

**Causa**: Não usou `--yolo` ou `--approval-mode auto_edit`

**Solução**:
```bash
# Adicionar --yolo
gemini -p "..." --yolo

# Ou aprovar apenas edições
gemini -p "..." --approval-mode auto_edit
```

### Erro: "MCP server not available in sandbox"

**Causa**: MCP server não está disponível dentro do sandbox

**Solução**:
- Instalar MCP server dentro da imagem Docker do sandbox
- Ou usar `--approval-mode yolo` sem `--sandbox`
- Ou configurar MCP server para ser acessível externamente

## Boas Práticas

1. **Sempre use `--yolo` em orquestração autônoma**
   - O Orchestrator (Sonnet) supervisiona a execução
   - Contexto é fornecido explicitamente
   - Resultados são validados no final

2. **Configure `trust: true` para MCP conhecidos**
   - Basic Memory MCP (oficial)
   - Backlog.md MCP (oficial)
   - Seus próprios servidores MCP

3. **Use allowlists em ambientes críticos**
   - CI/CD em produção
   - Ambientes compartilhados
   - Workflows com múltiplos usuários

4. **Teste sem `--yolo` primeiro**
   - Para validar prompts
   - Para entender comportamento do agente
   - Para ajustar contexto antes de autonomia completa

5. **Documente suas configurações**
   - Mantenha `settings.json` versionado
   - Documente flags usadas em scripts
   - Anote configurações específicas por projeto
