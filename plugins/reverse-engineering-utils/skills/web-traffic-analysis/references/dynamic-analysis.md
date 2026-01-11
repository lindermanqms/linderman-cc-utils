# Dynamic Analysis & Advanced Techniques

Quando a análise estática de arquivos HAR não é suficiente (por exemplo, devido a criptografia no front-end, tokens rotativos ou fluxos complexos), métodos dinâmicos são necessários.

## 1. Ferramentas de Proxy (Interceptação)

### Mitmproxy (Open Source)
Permite interceptar e modificar o tráfego em tempo real usando scripts Python.

*   **Instalação**: `pip install mitmproxy`
*   **Uso**: Escreva um script Python que o `mitmproxy` carrega.
*   **Vantagem**: Teste de replay attacks e modificação de payloads "on-the-fly".

```python
# Exemplo básico de interceptor
from mitmproxy import http, ctx

def request(flow: http.HTTPFlow):
    if "api.exemplo.com" in flow.request.pretty_url:
        ctx.log.info(f"Intercepted API call: {flow.request.path}")
```

### Outras Opções de Proxy
*   **Burp Suite Community**: Padrão da indústria. Ótimo para fuzzing (Intruder) e replay manual (Repeater).
*   **OWASP ZAP**: Melhor alternativa open-source ao Burp. Possui scanner automático e fuzzer.
*   **HTTP Toolkit**: Interface moderna e setup "zero-config". Ótimo para iniciantes.
*   **Proxyman (macOS)**: Interface nativa e excelente visualização de tráfego.

## 2. Chrome DevTools Protocol (CDP)

O CDP permite controlar o navegador em baixo nível, ideal para contornar proteções que dependem de renderização ou execução de JS no cliente.

### Uso com Selenium (Python)
```python
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

driver = webdriver.Chrome()

# Habilitar interceptação de rede via CDP
if hasattr(driver, 'execute_cdp_cmd'):
    driver.execute_cdp_cmd('Network.enable', {})
    driver.execute_cdp_cmd('Network.setUserAgentOverride', {
        "userAgent": "Mozilla/5.0 (Custom User-Agent)"
    })

driver.get('https://seu-site.com')
```

### Chrome DevTools MCP (Model Context Protocol)
Uma ferramenta recente (2025) que permite que agentes de IA (como Claude) interajam diretamente com o DevTools.
*   **Instalação**: `pip install chrome-devtools-mcp`
*   **Capacidades**: Inspecionar rede, executar JS, screenshots, simular geolocalização.

## 3. Automação de Browser (Playwright)

Para sites com muita criptografia no cliente ou CSRF tokens agressivos, o Playwright é superior ao Requests por executar o JS real.

*   **Network Interception**: O Playwright permite ouvir eventos de rede (`page.on("request")`).

```python
# Exemplo conceitual com Playwright
async def run(playwright):
    browser = await playwright.chromium.launch()
    page = await browser.new_page()

    # Capturar requisições
    page.on("request", lambda request: print(f"Request: {request.url}"))

    await page.goto("https://sistema-complexo.com")
    # ... realizar login ...
```

## 4. GraphQL Introspection

Se a API for GraphQL, use ferramentas específicas para descobrir o schema.

*   **Introspection Query**: Envie uma query especial para descobrir tipos e campos.
    ```bash
    curl -X POST -H "Content-Type: application/json" \
      -d '{"query":"{ __schema { types { name } } }"}' \
      https://seu-site.com/graphql
    ```
*   **Ferramentas**: [GrabGraphQL](https://grabgraphql.com) para capturar tráfego mesmo com introspection desabilitado.

## 5. Conversão Direta (har2requests)

Ferramentas que convertem o HAR diretamente em código Python "bruto".

*   **Ferramentas**: `har2requests` ou `har2py`.
*   **Comando**: `har2requests input.har > output.py`
*   **Workflow**: Gera um script que replica exatamente as requisições. Use-o como base e peça para uma LLM: *"Refatore este código para ser uma classe reutilizável"*.
