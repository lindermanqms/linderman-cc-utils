# JavaScript Deobfuscation & Analysis

Muitas vezes, a lógica de geração de tokens ou assinaturas de API está escondida em código JavaScript ofuscado ou minificado. Esta referência cobre ferramentas e técnicas para analisar esse código.

## 1. Ferramentas Online (Grátis)

Para análises rápidas sem instalar nada:

| Ferramenta | URL | Características |
|-----------|-----|-----------------|
| **de4js** | [lelinhtinh.github.io/de4js](https://lelinhtinh.github.io/de4js/) | Suporta múltiplos deobfuscators e unpackers comuns. |
| **JSBeautifier** | [beautifier.io](https://beautifier.io/) | O padrão ouro para formatação/beautification. Simples e rápido. |
| **UnPacker** | [matthewfl.com/unPacker.html](https://matthewfl.com/unPacker.html) | Especializado em decodificar JS "packed" (p.ex. P.A.C.K.E.R). |
| **JS Deobfuscator** | [jsontotable.org](https://jsontotable.org/javascript-deobfuscator) | Bom para lidar com ofuscação baseada em hex/unicode. |

## 2. Ferramentas CLI e Locais

Para integrar em scripts ou pipelines de análise:

### JS-Beautify
```bash
npm install -g js-beautify
js-beautify ofuscado.js > limpo.js
```

### JSimplifier (Avançado)
Para código pesadamente ofuscado que usa técnicas de controle de fluxo complexas.
*   **GitHub:** [JSimplifier](https://github.com/JSimplifier/JSimplifier)
*   **Técnicas:** Análise estática (AST), tracing dinâmico e renomeação de identificadores com LLM.

## 3. Script Python para Extração de Segredos

Use este script para varrer arquivos JS (já formatados) em busca de endpoints e chaves expostas.

```python
import re

def decode_hex_strings(js_code: str) -> str:
    """Decodifica strings em hex (\\x ou \\u) frequentemente usadas para esconder URLs"""
    # \\x notation
    js_code = re.sub(r'\\x([0-9a-fA-F]{2})',
                      lambda m: chr(int(m.group(1), 16)), js_code)

    # \\u notation
    js_code = re.sub(r'\\u([0-9a-fA-F]{4})',
                      lambda m: chr(int(m.group(1), 16)), js_code)

    return js_code

def extract_api_endpoints(js_code: str) -> list:
    """Extrai URLs/endpoints do código JS"""
    patterns = [
        r'["\']https?://[^"\']+["\']',  # URLs completas
        r'["\']\/api\/[^"\']+["\']',    # Caminhos relativos começando com /api/
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
        'api_keys': re.findall(r'api[_-]?key[\'\"]\s*[:=]\s*[\'\"](.*?)[\'\"]', js_code, re.IGNORECASE),
        'tokens': re.findall(r'token\s*[:=]\s*[\'\"](.*?)[\'\"]', js_code, re.IGNORECASE),
        'auth_tokens': re.findall(r'auth[_-]?token\s*[:=]\s*[\'\"](.*?)[\'\"]', js_code, re.IGNORECASE),
    }
    return {k: v for k, v in secrets.items() if v}

# Exemplo de uso
# with open('app.js', 'r') as f:
#     content = f.read()
#     decoded = decode_hex_strings(content)
#     print(extract_api_endpoints(decoded))
#     print(extract_keys_and_secrets(decoded))
```

## 4. Dicas de Engenharia Reversa Manual

1.  **Search Strings**: Procure por strings únicas que você viu nas requisições de rede (nomes de headers, partes da URL).
2.  **Breakpoints**: No DevTools (Sources tab), coloque breakpoints em XHR/Fetch breakpoints para pausar a execução exatamente quando a requisição é feita. Analise a Call Stack para achar a função geradora.
3.  **Local Storage**: Verifique `localStorage`, `sessionStorage` e Cookies no DevTools (Application tab) para encontrar onde os tokens são persistidos.
