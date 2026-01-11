# Chrome Extensions for Reverse Engineering

Extensões de navegador são ferramentas essenciais para interceptar, modificar e analisar tráfego diretamente no contexto do cliente. Abaixo estão as ferramentas mais recomendadas.

## 1. Requestly (Melhor Opção Geral)
*   **URL:** [Requestly na Chrome Web Store](https://chromewebstore.google.com/detail/mdnleldcmiljblolnjhpnblkcekpdkpa)
*   **Funcionalidades:**
    *   Intercepta e modifica requisições HTTP/HTTPS.
    *   Suporte nativo a GraphQL.
    *   Mock de respostas com status codes customizados.
    *   Redirect de URLs e swap de hosts (ex: Produção -> Staging).
    *   Delay/throttle para simular latência.
    *   Exporta/importa regras (JSON).
*   **Caso de Uso:** Testar APIs em produção substituindo o host por development, simular erros de API.

## 2. Postman Interceptor
*   **URL:** [Postman Interceptor](https://chromewebstore.google.com/detail/aicmkgpgakddgnaphngcjz7c3)
*   **Funcionalidades:**
    *   Captura requisições direto do navegador.
    *   Sincroniza cookies e headers com o Postman desktop.
*   **Caso de Uso:** Ideal se você já usa o ecossistema Postman para desenvolvimento e testes de API.

## 3. Tamper Chrome (Foco em Segurança)
*   **URL:** [Tamper Chrome](https://chromewebstore.google.com/detail/okhfletjajcajbdjbffomebieaefhjjj)
*   **Funcionalidades:**
    *   Interceptação em tempo real.
    *   Suporte a WebSocket.
    *   Integração profunda com Chrome DevTools.

## 4. ModHeader (Simples e Leve)
*   **URL:** [ModHeader](https://chromewebstore.google.com/detail/idgpnmonknjnrjmuyxlyucjenyocjipm)
*   **Funcionalidades:**
    *   Focado exclusivamente em modificação de headers.
    *   Sem overhead de processamento.
*   **Caso de Uso:** Adicionar headers de `Authorization` ou contornar verificações de CORS simples.

## 5. Easy Interceptor (Open Source)
*   **GitHub:** [Easy Interceptor](https://github.com/hans000/easy-interceptor)
*   **Funcionalidades:**
    *   Intercepta `XMLHttpRequest` e `Fetch`.
    *   Simples e leve.

## Setup Recomendado para o Agente

Para facilitar a análise de tráfego que será processada posteriormente:

1.  **Instale o Requestly**: Sua interface visual facilita a criação de regras complexas.
2.  **Configure Regras de Log**:
    *   Crie regras para logar todas as requisições GraphQL ou de endpoints específicos.
    *   Adicione headers de debug (`X-Debug-Trace`) se o backend suportar.
3.  **Redirecionamento**: Use regras de redirect para testar endpoints locais contra o frontend de produção.
