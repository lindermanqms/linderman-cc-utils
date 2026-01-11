# HAR Processing Strategy

Arquivos HAR (HTTP Archive) são registros que podem ser muito extensos (50-500MB). Para engenharia reversa com LLMs, é essencial pré-processar e extrair apenas a estrutura semântica das requisições, removendo ruídos como imagens, CSS e fontes.

## Script de Filtragem e Redução (Python)

Este script transforma um HAR de grande porte em um JSON compacto, ideal para análise por IA.

### Funcionalidades
1.  **Filtra por MIME Type**: Remove imagens, fontes, CSS, vídeos.
2.  **Remove Assets Estáticos**: Ignora URLs de analytics, CDN, JS, etc.
3.  **Limpa Headers**: Mantém apenas headers relevantes para autenticação e contexto (Authorization, X-API-Key, etc).
4.  **Esquematiza o Payload**: Extrai apenas as chaves (keys) de JSONs grandes, evitando estourar o contexto da LLM.
5.  **Trata Body de Requests**: Processa POST/PUT bodies.

### Pré-requisitos

```bash
pip install python-json-logger jq python-dateutil
```

### Código Python (`filter_har.py`)

```python
# /// script
# dependencies = [
#   "python-json-logger",
#   "jq",
#   "python-dateutil"
# ]
# ///
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
    try:
        with open(har_file_path, 'r', encoding='utf-8') as f:
            har_data = json.load(f)
    except FileNotFoundError:
        print(json.dumps({"error": f"File not found: {har_file_path}"}))
        return "{}"
    except json.JSONDecodeError:
        print(json.dumps({"error": f"Invalid JSON in file: {har_file_path}"}))
        return "{}"

    filtered_entries = []

    if 'log' not in har_data or 'entries' not in har_data['log']:
         print(json.dumps({"error": "Invalid HAR structure"}))
         return "{}"

    for entry in har_data['log']['entries']:
        req = entry['request']
        res = entry['response']

        # Skip imagens, CSS, fonts baseado no MIME type
        mime_type = res['content'].get('mimeType', '')
        if any(skip in mime_type for skip in ['image/', 'font/', 'audio/', 'video/']):
            continue

        # Skip assets estáticos baseado na URL
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
        print("Usage: uv run filter_har.py <path_to_har_file> [output.json]")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else 'filtered_api.json'

    filtered = filter_har(input_file)

    # Se output file foi passado ou se o user quer salvar (comportamento padrão se >2 args)
    if len(sys.argv) > 2:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(filtered)
        print(f"✓ HAR filtrado salvo em: {output_file}")
    else:
        # Se apenas 1 arg, imprime no stdout (comportamento para pipe)
        print(filtered)
```

### Como Executar

Salve o código acima como `filter_har.py` e execute usando `uv`:

```bash
uv run filter_har.py seu_arquivo.har api_endpoints.json
```

O arquivo JSON gerado (`api_endpoints.json`) conterá apenas os dados essenciais para o agente de IA analisar, reduzindo drasticamente o número de tokens necessários.
