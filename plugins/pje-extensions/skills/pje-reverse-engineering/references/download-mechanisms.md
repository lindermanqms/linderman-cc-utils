# Mecanismos de Download - PJe TRF5

## Visão Geral
Este documento detalha os métodos descobertos para download de PDFs de processos judiciais do sistema PJe, incluindo técnicas de chunking para arquivos grandes.

## 1. Download de Processo Completo (PDF)

### 1.1. Conceitos Fundamentais

**JSF ViewState**:
- Campo oculto: `javax.faces.ViewState`
- Token de segurança que valida estado da página
- Dinâmico: muda a cada carregamento
- Obrigatório: falha sem ele

**Autenticação**:
- Via cookies de sessão (ver `authentication.md`)
- Opção: `credentials: 'include'` no fetch

### 1.2. Fluxo de Download (3 Etapas)

#### Etapa 1: Navegar para Página do Processo
- **URL**: `https://{domain}/pje/Processo/ConsultaProcesso/Detalhe/listAutosDigitais.seam`
- **Parâmetros**: `?idProcesso={id}&ca={chave}&idTaskInstance={taskId}`
- **Método**: Via Selenium ou navegador controlado
- **Objetivo**: Carregar página para obter ViewState dinâmico

#### Etapa 2: Extrair ViewState
- **Seletor**: `input[name="javax.faces.ViewState"]`
- **Extração**: Atributo `value` do elemento
- **Contexto**: Deve ser feito com página carregada (Selenium/Content Script)

#### Etapa 3: Requisição POST de Download

**URL**: Mesma da Etapa 1
**Método**: POST
**Content-Type**: `application/x-www-form-urlencoded`

**Payload Completo**:
```python
form_data = {
    "navbar:inativacaoLembreteMsgsOpenedState": "",
    "navbar:cbTipoDocumento": "0",
    "navbar:idDe": "",
    "navbar:idAte": "",
    "navbar:dtInicioInputDate": "",
    "navbar:dtInicioInputCurrentDate": "07/2025",
    "navbar:dtFimInputDate": "",
    "navbar:dtFimInputCurrentDate": "07/2025",
    "navbar:cbCronologia": "ASC",
    "navbar:downloadProcesso": "Download",  # GATILHO
    "navbar": "navbar",
    "autoScroll": "",
    "javax.faces.ViewState": view_state  # TOKEN DINÂMICO
}
```

**CRÍTICO - Não Simplificar**:
- Todos os campos devem estar presentes
- Campos vazios são necessários
- Remoção de qualquer campo pode causar falha silenciosa
- Estrutura replicada de análise de network trace

**Resposta**:
- Content-Type: `application/pdf`
- Body: Binário do PDF completo

### 1.3. Implementação - JavaScript (Extension)

```javascript
// Background Script
const downloadUrl = `${baseUrl}/pje/Processo/ConsultaProcesso/Detalhe/listAutosDigitais.seam`;

const formData = new URLSearchParams();
formData.append("navbar:inativacaoLembreteMsgsOpenedState", "");
formData.append("navbar:downloadProcesso", "Download");
formData.append("javax.faces.ViewState", viewState);
// ... outros campos ...

fetch(downloadUrl, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: formData,
    credentials: "include"
})
.then(res => res.arrayBuffer())
.then(pdfBuffer => {
    // Processar PDF
});
```

### 1.4. Implementação - Python (Selenium + Requests)

```python
import requests
from selenium import webdriver
from selenium.webdriver.common.by import By

# 1. Login via Selenium e extração de cookies
# ... (ver authentication.md) ...

# 2. Navegar para página do processo
driver.get(f"https://pje1g.trf5.jus.br/pje/Processo/ConsultaProcesso/Detalhe/listAutosDigitais.seam?idProcesso={id_processo}")

# 3. Extrair ViewState
view_state = driver.find_element(By.NAME, "javax.faces.ViewState").get_attribute("value")

# 4. Requisição POST
download_url = "https://pje1g.trf5.jus.br/pje/Processo/ConsultaProcesso/Detalhe/listAutosDigitais.seam"
form_data = {
    # ... payload completo ...
    "javax.faces.ViewState": view_state
}

response = http_session.post(download_url, data=form_data)

if response.status_code == 200 and 'application/pdf' in response.headers.get('Content-Type', ''):
    with open("processo.pdf", 'wb') as f:
        f.write(response.content)
```

## 2. Técnica de Chunking para Arquivos Grandes

### 2.1. Problema
- PDFs de processos podem ter 50-100+ MB
- Chrome Extension Message Passing tem limite de payload
- Transferência direta causa timeout/crash

### 2.2. Solução: Fatiamento (Chunking)

**Conceito**:
1. Background script baixa PDF completo
2. Converte ArrayBuffer → Array de bytes (serializável)
3. Fatia string JSON em pedaços (chunks) de 5MB
4. Envia cada chunk sequencialmente para UI
5. UI remonta chunks → reconstituindo arquivo original

### 2.3. Implementação

**Constantes**:
```javascript
const MESSAGE_ID = 'chunked-pdf-transfer';
const CHUNK_SIZE = 5 * 1024 * 1024; // 5MB
```

**Lado Remetente (Background)**:
```javascript
export async function sendChunkedMessageToTab(tabId, payload) {
  const serializablePayload = {
    ...payload,
    data: Array.from(new Uint8Array(payload.data)), // ArrayBuffer → Array
  };

  const messageId = self.crypto.randomUUID();
  const dataStr = JSON.stringify(serializablePayload);
  const totalChunks = Math.ceil(dataStr.length / CHUNK_SIZE);

  for (let i = 0; i < totalChunks; i++) {
    const chunk = dataStr.substring(i * CHUNK_SIZE, (i + 1) * CHUNK_SIZE);

    await chrome.tabs.sendMessage(tabId, {
      identifier: MESSAGE_ID,
      messageId,
      index: i,
      chunk,
      totalChunks,
    });
  }
}
```

**Lado Destinatário (UI)**:
```javascript
export function createChunkedMessageListener(onComplete) {
  const chunkStorage = {};

  return (message) => {
    if (message.identifier !== MESSAGE_ID) return;

    const { messageId, index, chunk, totalChunks } = message;

    if (!chunkStorage[messageId]) {
      chunkStorage[messageId] = new Array(totalChunks);
    }

    chunkStorage[messageId][index] = chunk;
    const receivedChunks = chunkStorage[messageId].filter(c => c !== undefined).length;

    if (receivedChunks === totalChunks) {
      const fullStr = chunkStorage[messageId].join('');
      delete chunkStorage[messageId];

      const fullPayload = JSON.parse(fullStr);
      fullPayload.data = new Uint8Array(fullPayload.data).buffer; // Array → ArrayBuffer
      onComplete(fullPayload);
    }
  };
}
```

## 3. Troubleshooting

### 3.1. Erro: ViewState Não Encontrado
- Verificar se página carregou completamente
- Seletor pode ter mudado na nova versão do PJe
- Usar inspeção de elementos para validar

### 3.2. Erro: Resposta HTML em vez de PDF
- Verificar payload completo (não simplificar)
- Conferir headers (Content-Type correto)
- Validar autenticação (cookies presentes)
