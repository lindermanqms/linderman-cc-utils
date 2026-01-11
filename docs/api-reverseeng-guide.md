# Guia Completo: Engenharia Reversa de APIs e Sites
## Para Agentes de IA - Automação com GEMINI-CLI e Antigravity

---

## SUMÁRIO EXECUTIVO

Este documento apresenta **todas as técnicas, ferramentas, scripts e dados** que um agente de IA pode utilizar para realizar engenharia reversa de APIs e sites. Inclui:

1. **Filtragem e pré-processamento de HAR files**
2. **Extensões Chrome e ferramentas do navegador**
3. **Scripts Python prontos para uso**
4. **Dados que o usuário deve fornecer**
5. **Técnicas dinâmicas (Playwright, Selenium, mitmproxy)**
6. **Autenticação, tokens e criptografia**
7. **Deobfuscação de JavaScript**
8. **Alternativas open-source a Burp Suite**

---

## SEÇÃO 1: PROCESSAMENTO INICIAL DE DADOS (HAR Files)

### 1.1 O Problema: HAR files são GIGANTESCOS

Um arquivo HAR capturado do navegador pode ter:
- **50-500 MB** para uma sessão de 5 minutos
- 95% é ruído: imagens em Base64, CSS minificado, fonts, timestamps
- **Ao passar para LLM: queima tokens em segundos**

### 1.2 Solução: Script de Filtragem Python

**Instale dependências:**
```bash
pip install python-json-logger jq python-dateutil
```

**Script: `filter_har.py`**
```python
import json
import sys
from urllib.parse import urlparse, parse_qs

def extract_json_keys(data, max_depth=2, current_depth=0):
    """
    Extrai apenas a estrutura (keys) de um JSON sem os valores.
    Limita profundidade para evitar explosão de estrutura.
    """
    if current_depth >= max_depth:
        return f"<max_depth_reached: {type(data).__name__}>"
    
    if isinstance(data, dict):
        if len(data) > 50:  # Limita para dicts grandes
            return {"_keys": list(data.keys())[:20], "_truncated": len(data) - 20}
        return {k: extract_json_keys(v, max_depth, current_depth + 1) for k, v in data.items()}
    elif isinstance(data, list):
        if len(data) > 0:
            return [extract_json_keys(data[0], max_depth, current_depth + 1)]
        return []
    else:
        return f"<{type(data).__name__}>"

def filter_har(har_file_path):
    """
    Filtra HAR mantendo apenas endpoints de API (JSON/GraphQL).
    Remove: imagens, CSS, fonts, analytics, ads.
    """
    with open(har_file_path, 'r', encoding='utf-8') as f:
        har_data = json.load(f)
    
    filtered_entries = []
    
    for entry in har_data['log']['entries']:
        req = entry['request']
        res = entry['response']
        
        # Skip imagens, CSS, fonts
        mime_type = res['content'].get('mimeType', '')
        if any(skip in mime_type for skip in ['image/', 'font/', 'audio/', 'video/']):
            continue
        
        # Skip assets estáticos
        url_lower = req['url'].lower()
        if any(skip in url_lower for skip in ['.css', '.js', '.woff', '.ttf', 'cdn.', 'analytics', 'google-analytics']):
            continue
        
        # Tenta extrair payload de resposta
        response_payload = None
        response_status = res['status']
        
        if 'text' in res['content'] and res['content']['text']:
            try:
                response_payload = json.loads(res['content']['text'])
                # Se JSON é muito grande, apenas extrai keys
                if len(json.dumps(response_payload)) > 5000:
                    response_payload = extract_json_keys(response_payload, max_depth=2)
            except json.JSONDecodeError:
                response_payload = res['content']['text'][:500] if res['content']['text'] else None
        
        # Extrai headers relevantes (auth, content-type, etc)
        relevant_headers = {}
        for header in req['headers']:
            name_lower = header['name'].lower()
            if any(key in name_lower for key in ['authorization', 'x-api-key', 'content-type', 'accept', 'x-csrf', 'x-requested-with']):
                relevant_headers[header['name']] = header['value']
        
        # Extrai query parameters
        query_params = {}
        if '?' in req['url']:
            parsed_url = urlparse(req['url'])
            query_params = parse_qs(parsed_url.query)
        
        # Extrai body da request (se POST/PUT/PATCH)
        request_body = None
        if req['method'] in ['POST', 'PUT', 'PATCH']:
            if 'postData' in req and 'text' in req['postData']:
                try:
                    request_body = json.loads(req['postData']['text'])
                    if len(json.dumps(request_body)) > 3000:
                        request_body = extract_json_keys(request_body)
                except:
                    request_body = req['postData']['text'][:300]
        
        filtered_entries.append({
            'method': req['method'],
            'url': req['url'],
            'status_code': response_status,
            'query_params': query_params if query_params else None,
            'auth_headers': relevant_headers if relevant_headers else None,
            'request_body_structure': request_body,
            'response_structure': response_payload,
            'timing_ms': entry.get('timings', {}).get('total', 'N/A')
        })
    
    return json.dumps(filtered_entries, indent=2)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Uso: python filter_har.py <arquivo.har> [output.json]")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else 'filtered_api.json'
    
    filtered = filter_har(input_file)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(filtered)
    
    print(f"✓ HAR filtrado salvo em: {output_file}")
    print(f"✓ Tamanho reduzido")
```

**Uso:**
```bash
python filter_har.py meu_arquivo.har api_endpoints.json
# Arquivo de 200MB → 200KB (compressão de 1000x)
```

### 1.3 Alternativa: `mitmproxy2swagger`

Se já tem o fluxo capturado, converta diretamente para Swagger/OpenAPI:

```bash
pip install mitmproxy2swagger

# Capture usando mitmweb primeiro
mitmweb -p 8080

# Depois converta
mitmproxy2swagger -i ~/Downloads/flows -o api_spec.yml -p seu-dominio.com -f flow --examples
```

Isso gera um `api_spec.yml` pronto para importar no **Swagger Editor** (https://editor.swagger.io/).

---

## SEÇÃO 2: EXTENSÕES CHROME RECOMENDADAS

### 2.1 Principais Extensões

#### **A. Requestly** (Melhor overall)
- **URL:** https://chromewebstore.google.com/detail/mdnleldcmiljblolnjhpnblkcekpdkpa
- **Recursos:**
  - Intercepta e modifica requisições HTTP/HTTPS
  - Suporte nativo a GraphQL
  - Mock de respostas com status codes customizados
  - Redirect de URLs e swap de hosts
  - Delay/throttle para simular latência
  - Exporta/importa regras (JSON)

- **Uso ideal:** Testar APIs em produção substituindo o host por development

#### **B. Postman Interceptor**
- **URL:** https://chromewebstore.google.com/detail/aicmkgpgakddgnaphngcjz7c3
- **Recursos:**
  - Captura requisições direto do navegador
  - Sincroniza cookies, headers com Postman desktop
  - Ideal se você usa Postman

#### **C. Tamper Chrome** (Security-focused)
- **URL:** https://chromewebstore.google.com/detail/okhfletjajcajbdjbffomebieaefhjjj
- **Recursos:**
  - Interceptação em tempo real
  - Suporte a WebSocket
  - Integração com Chrome DevTools

#### **D. ModHeader** (Simples, leve)
- **URL:** https://chromewebstore.google.com/detail/idgpnmonknjnrjmuyxlyucjenyocjipm
- **Recursos:**
  - Focado em modificação de headers
  - Sem overhead de processamento
  - Perfeito para adicionar Authorization, CORS headers

#### **E. Easy Interceptor** (Open source)
- **GitHub:** https://github.com/hans000/easy-interceptor
- **Recursos:**
  - Intercepta XMLHttpRequest e Fetch
  - Simples e leve

### 2.2 Setup Recomendado

**Para trabalhar com o agente:**
1. **Instale Requestly** - Interface visual limpa
2. **Configure regras para:**
   - Log todas as requisições GraphQL
   - Redirecione URLs de produção para staging
   - Adicione headers de debug/trace

---

## SEÇÃO 3: FERRAMENTAS DE PROXY (Desktop)

### 3.1 mitmproxy (Open source, 100% gratuito)

**Instalação:**
```bash
# macOS
brew install mitmproxy

# Ubuntu/Debian
sudo apt-get install mitmproxy

# Ou via pip
pip install mitmproxy
```

**Iniciar interface web:**
```bash
mitmweb -p 8080
# Acesse http://localhost:8081
```

**Script Python para capturar/analisar:**
```python
from mitmproxy import http, ctx
import json

class APIInterceptor:
    def __init__(self):
        self.api_calls = []
    
    def request(self, flow: http.HTTPFlow) -> None:
        """Intercepta requisições"""
        if 'api' in flow.request.url or flow.request.method in ['POST', 'PUT', 'DELETE']:
            request_data = {
                'method': flow.request.method,
                'url': flow.request.url,
                'headers': dict(flow.request.headers),
                'body': flow.request.content.decode() if flow.request.content else None
            }
            ctx.log.info(f"Request: {request_data['method']} {request_data['url']}")
    
    def response(self, flow: http.HTTPFlow) -> None:
        """Intercepta respostas"""
        try:
            if 'api' in flow.request.url:
                response_data = {
                    'status': flow.response.status_code,
                    'headers': dict(flow.response.headers),
                    'body': flow.response.content.decode() if flow.response.content else None
                }
                self.api_calls.append({
                    'request': {
                        'method': flow.request.method,
                        'url': flow.request.url
                    },
                    'response': response_data
                })
        except Exception as e:
            ctx.log.error(f"Error: {e}")

addons = [APIInterceptor()]
```

**Executar com addon:**
```bash
mitmproxy -s interceptor.py -p 8080
```

### 3.2 Burp Suite Community Edition (Free!)

**Download:** https://portswigger.net/burp/communitydownload

**Features:**
- Proxy HTTP/HTTPS
- Intruder (fuzzing)
- Repeater (replay requisições)
- Scanner automático (Community limitado)
- Extensões via BApp Store

**Setup rápido:**
```bash
# Linux/Mac
./burpsuite_community_linux_v2025.10.7.sh

# Após iniciar, configure proxy em Settings > Network
```

### 3.3 HTTP Toolkit (Interface moderna)

**URL:** https://httptoolkit.tech/

**Vantagens sobre mitmproxy:**
- Setup one-click (sem configuração manual de proxy)
- Interface visual intuitiva
- Suporte a WebSocket (em breve melhorado)
- Disponível como Desktop + Web

---

## SEÇÃO 4: CAPTURA E ANÁLISE DE HAR

### 4.1 Exportar HAR do Chrome DevTools

**Passos:**
1. Abra DevTools (F12)
2. Aba **Network**
3. Realize as ações desejadas no site
4. Clique direito em qualquer requisição → **Save all as HAR with content**

### 4.2 Exportar HAR do Firefox

```javascript
// No Console do Firefox (F12 > Console)
// Usar a extensão Web Developer Tools ou exportar manualmente via "Save All As HAR"
```

### 4.3 Script para Analisar HAR

```python
import json
from collections import defaultdict

def analyze_har(har_file):
    """Analisa padrões em arquivo HAR"""
    with open(har_file, 'r') as f:
        har = json.load(f)
    
    endpoints = defaultdict(list)
    auth_tokens = []
    
    for entry in har['log']['entries']:
        req = entry['request']
        res = entry['response']
        
        # Agrupar por endpoint
        url_path = req['url'].split('?')[0]  # Remove query params
        endpoints[url_path].append({
            'method': req['method'],
            'status': res['status'],
            'timestamp': entry['startedDateTime']
        })
        
        # Procurar por tokens
        for header in req['headers']:
            if 'authorization' in header['name'].lower():
                auth_tokens.append({
                    'url': url_path,
                    'token_type': header['value'].split()[0] if header['value'] else 'Unknown',
                    'token_preview': header['value'][:50] + '...'
                })
    
    # Imprimir resumo
    print("=" * 60)
    print("ENDPOINTS DESCOBERTOS:")
    print("=" * 60)
    for endpoint, calls in sorted(endpoints.items()):
        methods = set(c['method'] for c in calls)
        print(f"  {endpoint}")
        print(f"    Métodos: {', '.join(methods)}")
        print(f"    Chamadas: {len(calls)}")
    
    print("\n" + "=" * 60)
    print("AUTENTICAÇÃO DETECTADA:")
    print("=" * 60)
    for token in auth_tokens[:5]:  # Mostrar primeiros 5
        print(f"  [{token['token_type']}] {token['url']}")
        print(f"    Token: {token['token_preview']}\n")
    
    return endpoints, auth_tokens

# Uso
endpoints, tokens = analyze_har('sua_captura.har')
```

---

## SEÇÃO 5: SCRIPTING COM PYTHON

### 5.1 Biblioteca: `requests` (HTTP básico)

```python
import requests
import json
from typing import Dict, Optional

class APIClient:
    def __init__(self, base_url: str, auth_token: Optional[str] = None):
        self.base_url = base_url
        self.session = requests.Session()
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (agente-de-ia/1.0)',
            'Accept': 'application/json'
        }
        
        if auth_token:
            self.headers['Authorization'] = f'Bearer {auth_token}'
    
    def get(self, endpoint: str, params: Dict = None) -> Dict:
        """GET request"""
        url = f"{self.base_url}/{endpoint}"
        resp = self.session.get(url, headers=self.headers, params=params, timeout=10)
        resp.raise_for_status()
        return resp.json()
    
    def post(self, endpoint: str, data: Dict, params: Dict = None) -> Dict:
        """POST request"""
        url = f"{self.base_url}/{endpoint}"
        resp = self.session.post(
            url,
            headers=self.headers,
            json=data,
            params=params,
            timeout=10
        )
        resp.raise_for_status()
        return resp.json()
    
    def put(self, endpoint: str, data: Dict) -> Dict:
        """PUT request"""
        url = f"{self.base_url}/{endpoint}"
        resp = self.session.put(url, headers=self.headers, json=data, timeout=10)
        resp.raise_for_status()
        return resp.json()
    
    def delete(self, endpoint: str) -> bool:
        """DELETE request"""
        url = f"{self.base_url}/{endpoint}"
        resp = self.session.delete(url, headers=self.headers, timeout=10)
        resp.raise_for_status()
        return resp.status_code in [200, 204]

# Uso
api = APIClient('https://api.seu-site.com', auth_token='seu_token_aqui')
resultado = api.get('users/123')
print(resultado)
```

### 5.2 Biblioteca: `httpx` (async support)

```python
import httpx
import asyncio

async def fetch_multiple_endpoints(base_url: str, endpoints: list, auth: str):
    """Busca múltiplos endpoints em paralelo"""
    async with httpx.AsyncClient(
        base_url=base_url,
        headers={'Authorization': f'Bearer {auth}'}
    ) as client:
        tasks = [client.get(ep) for ep in endpoints]
        responses = await asyncio.gather(*tasks)
        return [r.json() for r in responses]

# Uso
results = asyncio.run(fetch_multiple_endpoints(
    'https://api.seu-site.com',
    ['users', 'posts', 'comments'],
    'seu_token'
))
```

### 5.3 Biblioteca: `playwright` (Browser automation)

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    context = browser.new_context()
    
    # Interceptar requisições de rede
    def handle_route(route):
        print(f"URL: {route.request.url}")
        print(f"Headers: {route.request.headers}")
        print(f"Method: {route.request.method}")
        route.continue_()
    
    page = context.new_page()
    page.route('**/api/**', handle_route)
    
    page.goto('https://seu-site.com/login')
    page.fill('#username', 'seu_usuario')
    page.fill('#password', 'sua_senha')
    page.click('#login-btn')
    page.wait_for_navigation()
    
    # Agora extrair dados
    api_data = page.evaluate("""
        () => {
            return {
                user: window.__APP_STATE__.user,
                config: window.__APP_STATE__.config
            }
        }
    """)
    
    print(api_data)
    browser.close()
```

### 5.4 Geração de `har2py`

```bash
pip install har2py

har2py input.har > output.py
# Gera script Python que replica exatamente as requisições
```

---

## SEÇÃO 6: AUTENTICAÇÃO E TOKENS

### 6.1 Tipos Comuns

| Tipo | Header | Exemplo |
|------|--------|---------|
| **Bearer Token** | `Authorization: Bearer <token>` | JWT, OAuth2 access token |
| **API Key** | `X-API-Key: <key>` ou query param | Chave simples |
| **Basic Auth** | `Authorization: Basic base64(user:pass)` | Base64 encoded |
| **Session Cookie** | `Cookie: sessionid=<value>` | Cookie de sessão |
| **Custom Header** | Qualquer header customizado | `X-Auth-Token`, `X-Session-ID` |
| **Signed Requests** | Headers + HMAC signature | AWS SigV4, requests assinadas |

### 6.2 Extrair Token (Manual)

**Se o site usa bearer token:**
```javascript
// No Console do navegador (F12 > Console)
// Procurar em:
console.log(localStorage.getItem('auth_token'));
console.log(sessionStorage.getItem('token'));
console.log(document.cookie);

// Ou em window
console.log(window.__APP_STATE__);
console.log(window.__INITIAL_STATE__);
```

**Se o site usa JWT:**
```python
import jwt
import json
import base64

token = "seu_token_aqui"
# JWT é base64(header).base64(payload).signature

parts = token.split('.')
payload = base64.urlsafe_b64decode(parts[1] + '==')
decoded = json.loads(payload)
print(json.dumps(decoded, indent=2))
```

### 6.3 Refresh Tokens

Se você tem um refresh token, implemente refresh automático:

```python
import jwt
import time
from datetime import datetime

class AuthManager:
    def __init__(self, client_id: str, client_secret: str, token_endpoint: str):
        self.client_id = client_id
        self.client_secret = client_secret
        self.token_endpoint = token_endpoint
        self.access_token = None
        self.refresh_token = None
        self.token_expiry = None
    
    def refresh(self):
        """Faz refresh do token"""
        data = {
            'grant_type': 'refresh_token',
            'refresh_token': self.refresh_token,
            'client_id': self.client_id,
            'client_secret': self.client_secret
        }
        
        resp = requests.post(self.token_endpoint, json=data)
        resp.raise_for_status()
        
        token_data = resp.json()
        self.access_token = token_data['access_token']
        self.refresh_token = token_data.get('refresh_token', self.refresh_token)
        
        # Calcula expiração (assumindo expires_in em segundos)
        if 'expires_in' in token_data:
            self.token_expiry = time.time() + token_data['expires_in'] - 60
    
    def get_valid_token(self):
        """Retorna token válido, refreshando se necessário"""
        if not self.access_token or time.time() >= self.token_expiry:
            self.refresh()
        return self.access_token
```

---

## SEÇÃO 7: DEOBFUSCAÇÃO DE JAVASCRIPT

### 7.1 Tools Online (Grátis)

| Ferramenta | URL | Características |
|-----------|-----|-----------------|
| **de4js** | https://lelinhtinh.github.io/de4js/ | Suporta múltiplos deobfuscators |
| **JSBeautifier** | https://beautifier.io/ | Simples, rápido |
| **UnPacker** | https://matthewfl.com/unPacker.html | Decodifica packed JS |
| **JS Deobfuscator Online** | https://jsontotable.org/javascript-deobfuscator | Handles hex/unicode |

### 7.2 Ferramentas CLI

```bash
# Instalar js-beautify
npm install -g js-beautify

# Usar
js-beautify seu_arquivo.js > seu_arquivo_beautified.js
```

### 7.3 Deobfuscação com Python

```python
import re
import json

def decode_hex_strings(js_code: str) -> str:
    """Decodifica strings em hex (\\x ou \\u)"""
    # \\x notation
    js_code = re.sub(r'\\x([0-9a-fA-F]{2})', 
                      lambda m: chr(int(m.group(1), 16)), js_code)
    
    # \\u notation  
    js_code = re.sub(r'\\u([0-9a-fA-F]{4})', 
                      lambda m: chr(int(m.group(1), 16)), js_code)
    
    return js_code

def extract_api_endpoints(js_code: str) -> list:
    """Extrai URLs/endpoints do código JS"""
    # Procura por padrões comuns
    patterns = [
        r'["\']https?://[^"\']+["\']',  # URLs completas
        r'["\']\/api\/[^"\']+["\']',    # Caminhos relativos
        r'endpoint\s*[:=]\s*["\']([^"\']+)["\']',  # endpoint = "..."
        r'url\s*[:=]\s*["\']([^"\']+)["\']',  # url = "..."
    ]
    
    endpoints = []
    for pattern in patterns:
        matches = re.findall(pattern, js_code)
        endpoints.extend(matches)
    
    return list(set(endpoints))

def extract_keys_and_secrets(js_code: str) -> dict:
    """Procura por chaves/secrets que podem estar em claro"""
    secrets = {
        'api_keys': re.findall(r'api[_-]?key[\'\"]\s*[:=]\s*[\'\"](.*?)[\'\"]', js_code),
        'tokens': re.findall(r'token\s*[:=]\s*[\'\"](.*?)[\'\"]', js_code),
        'auth_tokens': re.findall(r'auth[_-]?token\s*[:=]\s*[\'\"](.*?)[\'\"]', js_code),
    }
    return {k: v for k, v in secrets.items() if v}

# Uso
with open('obfuscated.js', 'r') as f:
    js = f.read()

js_decoded = decode_hex_strings(js)
endpoints = extract_api_endpoints(js_decoded)
secrets = extract_keys_and_secrets(js_decoded)

print(f"Endpoints encontrados: {endpoints}")
print(f"Secrets detectados: {secrets}")
```

### 7.4 JSimplifier (Ferramenta Avançada)

Para código muito ofuscado, use o JSimplifier (GitHub). Ele usa:
- AST-based static analysis
- Dynamic execution tracing
- LLM-enhanced identifier renaming

```bash
git clone https://github.com/JSimplifier/JSimplifier.git
cd JSimplifier
python jsimplifier.py seu_arquivo.js
```

---

## SEÇÃO 8: CHROME DEVTOOLS PROTOCOL (CDP)

### 8.1 Usar CDP com Selenium (Python)

```python
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chromium.webdriver import ChromiumDriver
from selenium.webdriver.common.devtools.v85 import network

options = Options()
driver = webdriver.Chrome(options=options)

# Habilitar CDP
if hasattr(driver, 'execute_cdp_cmd'):
    # Habilitar network tracking
    driver.execute_cdp_cmd('Network.enable', {})
    
    # Interceptar requisições
    driver.execute_cdp_cmd('Network.setUserAgentOverride', {
        "userAgent": "Mozilla/5.0 (Custom User-Agent)"
    })
    
    # Simular latência
    driver.execute_cdp_cmd('Network.emulateNetworkConditions', {
        "offline": False,
        "downloadThroughput": 1000 * 1024 / 8,  # 1 Mbps
        "uploadThroughput": 1000 * 1024 / 8,
        "latency": 100  # 100ms
    })

driver.get('https://seu-site.com')
time.sleep(2)

# Acessar console logs
logs = driver.get_log('performance')
for log in logs:
    print(log)

driver.quit()
```

### 8.2 MCP (Model Context Protocol) - Chrome DevTools

**Nova ferramenta (2025):** Chrome team lançou Chrome DevTools MCP

```bash
# Usar com Claude/Anthropic
pip install chrome-devtools-mcp

# Permite que agente de IA acesse DevTools diretamente
```

**Capacidades:**
- Inspecionar requisições de rede
- Interceptar e modificar headers
- Executar JavaScript no contexto da página
- Capturar screenshots
- Simular geolocalização, device profiles

---

## SEÇÃO 9: DADOS QUE O USUÁRIO DEVE FORNECER

### 9.1 Essenciais

```
DADOS CRÍTICOS PARA O AGENTE:

1. **URL do Site/API**
   - URL completa: https://seu-site.com
   - Endpoints conhecidos (ex: /api/v1/, /graphql)

2. **Credenciais (se necessário)**
   - Username / Email
   - Senha
   - 2FA se houver (TOTP secret ou recovery codes)

3. **Arquivo HAR** (já capturado e filtrado)
   - Resultado do script filter_har.py
   - Contém: endpoints, headers, payloads

4. **Comportamento Esperado**
   - "Fazer login, depois acessar dashboard"
   - "Listar todos os usuários"
   - "Criar um novo item"

5. **Ambiente/Credenciais da API**
   - API Key (se pública)
   - OAuth credentials
   - Client ID/Secret
```

### 9.2 Provender ao Agente (Prompt Recomendado)

```plaintext
Você é um especialista em engenharia reversa de APIs.

DADOS FORNECIDOS:
1. HAR filtrado: [arquivo_json acima]
2. Autenticação: Bearer token (veja section: auth_headers)
3. Objetivo: Criar um cliente Python reutilizável para essa API

TAREFAS:
1. Identifique todos os endpoints (GET, POST, PUT, DELETE)
2. Mapeie os payloads de request/response
3. Identifique padrões de paginação
4. Crie uma classe Python `APIClient` com:
   - Método para cada ação identificada
   - Tratamento de erros
   - Rate limiting (se detectado)
5. Gere exemplos de uso

FORMATO DE SAÍDA: Código Python pronto para executar
```

---

## SEÇÃO 10: TÉCNICAS AVANÇADAS

### 10.1 GraphQL Introspection

Se a API usa GraphQL:

```bash
# Ferramentas específicas para GraphQL
pip install graphql-core graphql-cli

# Fazer introspection query
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name } } }"}' \
  https://seu-site.com/graphql
```

**Tool:** GrabGraphQL (https://grabgraphql.com)
- Captura tráfego GraphQL mesmo com introspection desabilitado
- Exporta para Postman, HAR, cURL

### 10.2 Mobile API Reverse Engineering

Se o target é um app mobile:

```bash
# Android
# 1. Extrair APK
adb pull /data/app/com.seu.app/base.apk

# 2. Decompile
pip install apktool
apktool d base.apk -o app_source

# 3. Procurar por URLs/endpoints
grep -r "http" app_source/

# 4. Análise avançada
# Usar JADX-GUI para decompile Java
```

```bash
# iOS (com acesso ao device)
# Usar Frida para hooking dinâmico
pip install frida frida-tools

# Hook URLSession
frida-trace -U -n "seu_app" -i "*URLSession*"
```

### 10.3 Criptografia e Signature

Se requisições são assinadas/criptografadas:

```python
import hashlib
import hmac
import json
from datetime import datetime

class SignedAPIClient:
    def __init__(self, api_key: str, api_secret: str):
        self.api_key = api_key
        self.api_secret = api_secret
    
    def create_signature(self, method: str, url: str, body: dict = None) -> str:
        """
        Cria assinatura HMAC-SHA256
        Padrão comum em APIs
        """
        timestamp = str(int(datetime.utcnow().timestamp()))
        
        # Montar string para assinar
        payload = f"{method}\n{url}\n{timestamp}"
        if body:
            payload += f"\n{json.dumps(body)}"
        
        # Gerar assinatura
        signature = hmac.new(
            self.api_secret.encode(),
            payload.encode(),
            hashlib.sha256
        ).hexdigest()
        
        return signature, timestamp
    
    def get(self, url: str):
        sig, ts = self.create_signature('GET', url)
        
        headers = {
            'X-API-Key': self.api_key,
            'X-Signature': sig,
            'X-Timestamp': ts
        }
        
        return requests.get(url, headers=headers)
```

### 10.4 Replay Ataques (Teste de Segurança)

```python
def test_request_replay(har_file: str, endpoint_index: int = 0):
    """
    Testa se um endpoint é vulnerável a replay attacks
    """
    with open(har_file) as f:
        har = json.load(f)
    
    entry = har['log']['entries'][endpoint_index]
    req = entry['request']
    
    # Repetir a mesma requisição múltiplas vezes
    for attempt in range(3):
        try:
            resp = requests.request(
                method=req['method'],
                url=req['url'],
                headers={h['name']: h['value'] for h in req['headers']},
                json=json.loads(req['postData']['text']) if 'postData' in req else None,
                timeout=5
            )
            
            print(f"Attempt {attempt + 1}: {resp.status_code}")
            if resp.status_code == 200:
                print(f"  ⚠️  VULNERÁVEL A REPLAY: {resp.status_code}")
            else:
                print(f"  ✓ Protected (diferentes respostas)")
        
        except Exception as e:
            print(f"  ✓ Erro na repetição: {e}")
```

---

## SEÇÃO 11: ALTERNATIVAS OPEN-SOURCE A BURP SUITE

### 11.1 OWASP ZAP (Melhor free alternative)

**Download:** https://www.zaproxy.org/

**Features:**
- Web application scanner automático
- Proxy interceptor (como Burp)
- Fuzzer integrado
- 100+ add-ons
- Totalmente gratuito e open-source
- Integração CI/CD

```bash
# Instalar
sudo apt install zaproxy

# CLI mode
zaproxy.sh -cmd \
  -quickurl https://seu-site.com \
  -quickout report.html
```

### 11.2 Hetty (Open-source, promissor)

**GitHub:** https://github.com/dstotijn/hetty

**Vantagens:**
- Escrito em Go (rápido)
- Interface web moderna
- Suporte a WebSocket
- Replay requests

```bash
# Instalar
go install github.com/dstotijn/hetty/cmd/hetty@latest

# Executar
hetty
# Acesse http://localhost:8080
```

### 11.3 Proxyman (macOS, gratuito)

**URL:** https://proxyman.io/

- Interface limpa (tipo Charles Proxy)
- Tls Breakdown
- Suporte a Websocket
- Native para macOS

---

## SEÇÃO 12: CHECKLIST COMPLETO PARA O AGENTE

```
[ ] 1. COLETA INICIAL
    [ ] Obter HAR file do navegador
    [ ] Rodar filter_har.py para reduzir tamanho
    [ ] Extrair credentials/tokens
    [ ] Listar todos os endpoints encontrados

[ ] 2. ANÁLISE
    [ ] Identificar padrões de request/response
    [ ] Mapear estrutura de autenticação
    [ ] Detectar GraphQL ou REST
    [ ] Procurar por endpoints não óbvios

[ ] 3. DEOBFUSCAÇÃO (se necessário)
    [ ] Procurar por JS ofuscado
    [ ] Usar de4js ou js-beautify
    [ ] Extrair endpoints/keys do código
    [ ] Analisar lógica de autenticação

[ ] 4. GERAÇÃO DE CLIENT
    [ ] Criar classe APIClient em Python
    [ ] Implementar autenticação
    [ ] Adicionar error handling
    [ ] Implementar rate limiting
    [ ] Gerar docstring com exemplos

[ ] 5. TESTES
    [ ] Testar cada endpoint
    [ ] Validar respostas contra schema extraído
    [ ] Testar casos de erro
    [ ] Testar autenticação/autorização

[ ] 6. DOCUMENTAÇÃO
    [ ] Criar README com setup
    [ ] Documentar cada método
    [ ] Fornecer exemplos de uso
    [ ] Listar limitações/gotchas
```

---

## SEÇÃO 13: PROMPT PARA PASSAR AO AGENTE

Use este prompt pronto para GEMINI-CLI ou Antigravity:

```plaintext
Atue como um Engenheiro de Software Especialista em Engenharia Reversa de APIs.

CONTEXTO:
Tenho um arquivo HAR filtrado (JSON) contendo requisições de rede de um site. 
Preciso criar um cliente Python que:
1. Replicar TODAS as chamadas de API identificadas
2. Manejar autenticação (veja headers de auth no JSON)
3. Ser reutilizável e bem-testado
4. Suportar paginação (se detectada)

DADOS FORNECIDOS:
[COLE AQUI O RESULTADO DE filter_har.py]

INSTRUÇÕES:
1. Analise o JSON e identifique:
   - Base URL da API
   - Endpoints únicos (agrupe por URL + método)
   - Estrutura de payloads (request/response)
   - Tipo de autenticação
   
2. Crie uma classe Python `APIClient` com:
   - __init__(base_url, auth_token)
   - Métodos para cada endpoint (ex: get_users(), create_post(), delete_item())
   - Tratamento de erros com logging
   - Type hints completos
   
3. Implemente detecção automática de:
   - Paginação (próxima página, total, etc)
   - Rate limiting (se houver headers de limite)
   - Retry automático em erros 5xx
   
4. Gere exemplos de uso pronto para copiar/colar

FORMATO:
```python
# Código bem formatado, pronto para usar
```

Finalize com:
- Lista de endpoints descobertos
- Endpoints não testáveis (endpoints de write que precisam de dados reais)
- Limitações conhecidas
```

---

## SEÇÃO 14: RECURSOS E LINKS

### Ferramentas
- Burp Suite: https://portswigger.net
- OWASP ZAP: https://zaproxy.org
- mitmproxy: https://mitmproxy.org
- Postman: https://postman.com
- Insomnia: https://insomnia.rest

### Bibliotecas Python
- requests: https://requests.readthedocs.io
- httpx: https://www.python-httpx.org
- playwright: https://playwright.dev
- selenium: https://selenium.dev

### Deobfuscação
- de4js: https://lelinhtinh.github.io/de4js/
- JSBeautifier: https://beautifier.io/
- JSimplifier: https://github.com/JSimplifier

### GraphQL
- GrabGraphQL: https://grabgraphql.com
- Apollo Studio: https://studio.apollographql.com

### Documentação
- OWASP API Security: https://owasp.org/www-project-api-security/
- REST API Best Practices: https://restfulapi.net/

---

## CONCLUSÃO

Este documento fornece **tudo** que um agente de IA precisa para:
1. ✅ Capturar tráfego de rede (HAR files)
2. ✅ Filtrar e processar dados (remover ruído)
3. ✅ Analisar endpoints e autenticação
4. ✅ Deobfuscar código JavaScript
5. ✅ Gerar clientes Python reutilizáveis
6. ✅ Testar e validar APIs

**Fluxo recomendado:**
1. Usuário captura HAR → `filter_har.py`
2. Usuário fornece arquivo filtrado ao agente
3. Agente analisa e cria cliente Python
4. Usuário testa cliente contra a API real

**Para sistemas críticos (como PJe do TRF5):**
- Use Playwright para contornar proteções JavaScript
- Implemente refresh de tokens automaticamente
- Adicione logging detalhado para debugging
- Considere usar MCP (Chrome DevTools) para visibilidade total

Boa sorte na automação! 🚀
