# Extração de Dados HTML - PJe TRF5

## Visão Geral
Nem todas as funcionalidades do PJe possuem endpoints REST JSON. Algumas seções retornam fragmentos HTML (RichFaces/JSF) que precisam ser parseados via scraping.

## 1. Conceitos de Tecnologia

### 1.1. Stack Tecnológica do PJe
- **JavaServer Faces (JSF)**: Framework de UI Java
- **RichFaces**: Biblioteca de componentes JSF
- **AJAX**: Atualizações parciais de página

### 1.2. Implicações para Scraping
- HTML gerado dinamicamente (não estático)
- Estrutura pode variar por versão do PJe
- Seletores CSS mais robustos que XPath
- IDs podem ser dinâmicos (ex: `j_id123`)

## 2. Caso de Uso: Extração de Expedientes

### 2.1. Contexto
**Objetivo**: Obter lista de comunicações (Ofícios, Mandados, Intimações) de um processo

**Localização**: Aba "Expedientes" na página de detalhes do processo

**Método**: Requisição GET que retorna HTML

### 2.2. A Requisição

#### URL e Parâmetros
**Endpoint**: `https://pje1g.trf5.jus.br/pje/Processo/ConsultaProcesso/Detalhe/listAutosDigitais.seam`

**Método**: GET

**Parâmetros Obrigatórios**:
- `idProcesso`: ID interno do processo (ex: `2781038`)
- `idTaskInstance`: ID da tarefa (opcional para leitura)
- `aba`: **CRÍTICO** - Valor: `processoExpedienteTab`
- `ca`: Chave de acesso (opcional se logado com cookies)

**Exemplo**:
```
https://pje1g.trf5.jus.br/pje/Processo/ConsultaProcesso/Detalhe/listAutosDigitais.seam?idProcesso=2781038&aba=processoExpedienteTab&ca=ABC123
```

#### Headers Necessários
```javascript
{
  "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
  "X-pje-usuario-localizacao": "25555",
  "Upgrade-Insecure-Requests": "1"
}
```

**Nota**: Cookies de sessão devem estar presentes (ver `authentication.md`)

### 2.3. Estrutura do HTML Retornado

#### Elemento Alvo Principal
**Tabela**: `#processoParteExpedienteMenuGridList`

**Linhas de Dados**: `.rich-table-row`

### 2.4. Mapeamento de Colunas

#### Coluna 0: Informações do Expediente

**Conteúdo**:
- Tipo e ID do expediente
- Destinatário
- Timeline de eventos
- Prazo relativo

**Extração via Regex**:
```javascript
// Tipo e ID
const match = text.match(/(Ofício|Mandado|Intimação|.*?)\s*\((\d+)\)/);
const tipo = match[1];
const id = match[2];

// Destinatário
const destinatarioMatch = text.match(/\(\d+\)\s*\n\s*([^\n]+)/);
const destinatario = destinatarioMatch[1];

// Prazo
const prazoMatch = text.match(/Prazo:\s*(.+?)(?:\n|$)/);
const prazo = prazoMatch[1];
```

#### Coluna 1: Data Limite do Prazo

**Conteúdo**: Data/hora ou vazio

**Seletor**: `div[id="r"]`

#### Coluna 2: Documentos e Ações

**Conteúdo**: Links para documentos relacionados

**Extração**:
```javascript
const links = cell.querySelectorAll('a');
const documentos = Array.from(links).map(link => ({
  nome: link.textContent.trim(),
  url: link.href
}));
```

#### Coluna 3: Status de Fechamento

**Conteúdo**: "SIM" ou "NÃO"

**Extração**:
```javascript
const status = cell.textContent.trim(); // "SIM" ou "NÃO"
```

### 2.5. Implementação Completa (JavaScript)

```javascript
function extrairExpedientes() {
  const expedientes = [];
  const table = document.querySelector('#processoParteExpedienteMenuGridList');

  if (!table) {
    return { erro: 'Tabela de expedientes não encontrada' };
  }

  const rows = table.querySelectorAll('tbody tr.rich-table-row');

  rows.forEach(row => {
    const cells = row.querySelectorAll('td');

    if (cells.length < 4) return;

    // Coluna 0
    const col0Text = cells[0].textContent;
    const tipoIdMatch = col0Text.match(/(Ofício|Mandado|Intimação|.*?)\s*\((\d+)\)/);

    // Coluna 1
    const dataLimiteEl = cells[1].querySelector('div[id="r"]');

    // Coluna 2
    const links = cells[2].querySelectorAll('a');

    // Coluna 3
    const fechado = cells[3].textContent.trim();

    expedientes.push({
      tipo: tipoIdMatch ? tipoIdMatch[1] : null,
      id: tipoIdMatch ? tipoIdMatch[2] : null,
      dataLimite: dataLimiteEl ? dataLimiteEl.textContent.trim() : null,
      documentos: Array.from(links).map(l => ({
        nome: l.textContent.trim(),
        url: l.href
      })),
      fechado: fechado === 'SIM'
    });
  });

  return expedientes;
}
```

## 3. Estratégias Gerais de Scraping

### 3.1. Seleção de Estratégia

**Use CSS Selectors quando**:
- ID/classe estáveis
- Estrutura hierárquica clara
- Exemplo: `#processoParteExpedienteMenuGridList tbody tr.rich-table-row`

**Use Regex quando**:
- Texto não estruturado
- Padrões específicos (números, datas, tipos)
- Exemplo: Extrair tipo e ID de expediente

**Use Combinação**:
- Seletor CSS para localizar elemento
- Regex para extrair dados do texto

### 3.2. Robustez e Manutenibilidade

#### Evitar IDs Dinâmicos
**Ruim**: `div[id="j_id123:infoPPE"]` (número muda)
**Bom**: `div[id$=":infoPPE"]` (termina com)

#### Priorizar Hierarquia
**Ruim**: `div.rich-table-cell` (genérico demais)
**Bom**: `#processoParteExpedienteMenuGridList tbody tr.rich-table-row td:nth-child(1)`

## 4. Ferramentas e Bibliotecas Recomendadas

### 4.1. JavaScript/Browser
- **Native DOM API**: `querySelector`, `querySelectorAll`
- **Cheerio** (Node.js): jQuery-like para HTML parsing
- **Puppeteer/Playwright**: Scraping com browser headless

### 4.2. Python
- **BeautifulSoup4**: HTML parsing robusto
- **lxml**: Parser rápido (backend do BS4)
- **Selenium**: Quando JavaScript dinâmico é necessário

## 5. Referências Cruzadas

- **Autenticação**: Ver `authentication.md` para gestão de cookies
- **API Endpoints**: Ver `api-endpoints.md` para obter IDs de processo
