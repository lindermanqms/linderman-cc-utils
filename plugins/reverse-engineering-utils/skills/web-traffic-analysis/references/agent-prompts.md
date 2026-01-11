# Prompts e Workflow para Agente de IA

Esta referência fornece os prompts otimizados e o workflow ideal para transformar dados brutos de análise de tráfego em clientes de API robustos usando LLMs (como Claude ou Gemini).

## 1. Checklist de Execução

Antes de iniciar a geração de código, verifique se você cumpriu as etapas abaixo. Isso garante que o agente tenha contexto suficiente.

```
[ ] 1. COLETA INICIAL
    [ ] Obter HAR file do navegador
    [ ] Rodar filter_har.py (veja har-processing.md) para reduzir tamanho
    [ ] Extrair credentials/tokens (se não estiverem óbvios no HAR)
    [ ] Listar todos os endpoints encontrados

[ ] 2. ANÁLISE
    [ ] Identificar padrões de request/response
    [ ] Mapear estrutura de autenticação (Bearer, Cookie, API Key)
    [ ] Detectar se é GraphQL ou REST
    [ ] Procurar por endpoints não óbvios

[ ] 3. DEOBFUSCAÇÃO (se necessário - veja javascript-deobfuscation.md)
    [ ] Procurar por JS ofuscado se a auth for complexa
    [ ] Extrair endpoints/keys hardcoded no código client-side

[ ] 4. GERAÇÃO DE CLIENT
    [ ] Criar classe APIClient em Python
    [ ] Implementar autenticação e refresh de token
    [ ] Adicionar error handling e logging
    [ ] Implementar rate limiting
    [ ] Gerar docstring com exemplos

[ ] 5. TESTES
    [ ] Validar respostas contra schema extraído
```

## 2. Dados Necessários

Para obter o melhor resultado, forneça explicitamente os seguintes dados no prompt:

1.  **URL Base**: (ex: `https://api.seu-site.com`)
2.  **Credenciais**: Tokens de exemplo ou instruções de como obter (ex: "Use o token que está no header Authorization").
3.  **Arquivo HAR Filtrado**: O JSON gerado pelo script `filter_har.py`.
4.  **Objetivo Específico**: (ex: "Quero apenas ler os dados de usuários" ou "Quero automatizar o cadastro de produtos").

## 3. System Prompt (Otimizado)

Copie este prompt e preencha a seção de DADOS para instruir o LLM.

```plaintext
Atue como um Engenheiro de Software Especialista em Engenharia Reversa de APIs.

CONTEXTO:
Tenho um arquivo HAR filtrado (JSON) contendo requisições de rede de um site alvo.
Preciso criar um cliente Python robusto e reutilizável para interagir com essa API.

DADOS FORNECIDOS:
[COLE AQUI O RESULTADO DE filter_har.py]

TAREFAS:
1. Analise o JSON fornecido e identifique:
   - Base URL da API
   - Endpoints únicos (agrupe por URL + método)
   - Estrutura de payloads (request body e response)
   - Padrão de Autenticação (Bearer, Cookie, Custom Header, etc)

2. Crie uma classe Python `APIClient` utilizando a biblioteca `requests` (ou `httpx` para async) contendo:
   - `__init__(self, ...)`: Configuração de sessão e autenticação.
   - Métodos tipados para cada endpoint identificado (ex: `get_users()`, `create_item(data)`).
   - Tratamento de erros (try/except, logging de falhas).
   - Type Hints para argumentos e retornos baseados na estrutura observada.

3. Implemente detecção automática (se possível com os dados):
   - Paginação (parâmetros como page, limit, offset).
   - Rate Limiting (headers de retry-after).

4. Gere exemplos de uso prático do cliente criado.

FORMATO DE SAÍDA:
Forneça apenas o código Python, seguido de uma breve lista de limitações conhecidas ou endpoints que requerem dados dinâmicos não capturados.
```

## 4. Refinamento de Autenticação

Se a autenticação for complexa (ex: assinatura HMAC ou tokens rotativos), adicione esta instrução ao prompt:

> "Atenção: A API parece usar uma assinatura HMAC no header 'X-Signature'. Crie um método auxiliar `_sign_request(payload)` na classe que gera essa assinatura baseada no timestamp atual e na Secret Key (assuma que a Secret Key será passada no `__init__`)."
