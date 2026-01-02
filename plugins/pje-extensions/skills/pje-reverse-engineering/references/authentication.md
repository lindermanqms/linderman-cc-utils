# Autenticação e Gestão de Sessão - PJe TRF5

## Visão Geral
O PJe TRF5 utiliza autenticação baseada em cookies de sessão combinada com headers customizados para autorização de operações.

## 1. Autenticação de Sessão

### 1.1. Cookies de Sessão
- **JSESSIONID**: Cookie principal de sessão JSF
- **oam.Flash.RENDERMAP.TOKEN**: Token de renderização
- Outros cookies gerados no login

### 1.2. Métodos de Login
1. **Usuário/Senha**: Login padrão via formulário
2. **Certificado Digital**: Método preferencial para servidores públicos
3. **SSO**: Integração com sistemas de Single Sign-On

### 1.3. Gestão de Cookies em Extensões

**Leitura de Cookies (Chrome Extension)**:
```javascript
const getPjeCookieString = async () => {
    const cookies = await chrome.cookies.getAll({
      url: "https://pje1g.trf5.jus.br/"
    });
    if (cookies.length === 0) return "";
    return cookies.map(cookie => `${cookie.name}=${cookie.value}`).join('; ');
};
```

**Inclusão em Fetch**:
- Opção 1: `credentials: 'include'` (automático para same-origin)
- Opção 2: Header customizado `X-pje-cookies` (para service workers)

## 2. Headers de Autenticação e Autorização

### 2.1. Headers Obrigatórios para API REST

```javascript
const createApiHeaders = async () => {
    const pjeCookies = await getPjeCookieString();
    return {
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json',
        'Authorization': 'Basic MDUyMDk0Mzc0MDA6MTIzNDU=',
        'X-Pje-Authorization': 'Basic MDUyMDk0Mzc0MDA6MTIzNDU=',
        'X-no-sso': 'true',
        'X-pje-legacy-app': 'pje-trf5-1g',
        'X-pje-usuario-localizacao': '25555',  // CRÍTICO
        'X-pje-cookies': pjeCookies,
    };
};
```

### 2.2. Análise dos Headers

**Authorization / X-Pje-Authorization**:
- Valor: `Basic MDUyMDk0Mzc0MDA6MTIzNDU=`
- Aparentemente estático (não muda por usuário)
- Decodificado: Base64 de credenciais genéricas
- **Hipótese**: Autenticação de aplicação, não de usuário

**X-pje-usuario-localizacao**:
- Valor: `25555`
- **CRÍTICO**: Obrigatório para todas operações de ESCRITA
- Ausência causa falhas silenciosas
- **Hipótese**: ID da localização/vara do usuário

**X-pje-legacy-app**:
- Valor: `pje-trf5-1g`
- Identifica a instância do PJe (1º grau)
- Outras variantes: `pje-trf5-2g` (2º grau)

**X-no-sso**:
- Valor: `true`
- Desabilita verificações de SSO

**X-pje-cookies**:
- Contém string de cookies formatada
- Necessário em contextos de service worker/background

### 2.3. Headers para Navegação HTML

Para requisições que retornam HTML (não JSON):
```javascript
{
  "Accept": "text/html,application/xhtml+xml...",
  "X-pje-usuario-localizacao": "25555",
  "Upgrade-Insecure-Requests": "1"
}
```

## 3. Autenticação em Diferentes Contextos

### 3.1. Extensão Chrome - Content Script
- **Contexto**: Executa na página do PJe
- **Cookies**: Acesso automático (mesmo domínio)
- **Fetch**: Usar `credentials: 'include'`

### 3.2. Extensão Chrome - Background/Service Worker
- **Contexto**: Isolado da página
- **Cookies**: Ler via `chrome.cookies.getAll()`
- **Fetch**: Incluir cookies via header `X-pje-cookies` ou `credentials: 'include'`

### 3.3. Aplicação Python/Selenium
- **Login**: Selenium para autenticação inicial
- **Extração**: `driver.get_cookies()` após login
- **Requests**: Transferir cookies para `requests.Session()`

```python
# Exemplo
selenium_cookies = driver.get_cookies()
http_session = requests.Session()
for cookie in selenium_cookies:
    http_session.cookies.set(cookie['name'], cookie['value'])
```

## 4. Validação de Sessão

### 4.1. Detecção de Sessão Expirada
- Status HTTP 401/403
- Redirecionamento para página de login
- Resposta JSON com `sucesso: false`

### 4.2. Renovação de Sessão
- Não há endpoint de refresh conhecido
- Necessário re-autenticar via login

## 5. Segurança e Boas Práticas

### 5.1. Nunca Hardcodar
- Cookies de sessão
- Tokens de acesso pessoais
- Certificados digitais

### 5.2. Proteção de Dados
- Cookies devem ser tratados como secrets
- Nunca logar cookies completos
- Sempre usar HTTPS

### 5.3. Timeout de Sessão
- PJe possui timeout de inatividade
- Implementar lógica de retry/re-login em aplicações automatizadas
