# Endpoints da API REST - PJe TRF5

## Informações Gerais
- **URL Base**: `https://pje1g.trf5.jus.br/pje/seam/resource/rest/pje-legacy/painelUsuario`
- **Protocolo**: REST API (JSON)
- **Autenticação**: Via headers (ver `authentication.md`)

## Catálogo de Endpoints

### 1. Processos

#### 1.1. Listar Processos de uma Tarefa
- **Endpoint**: `/recuperarProcessosTarefaPendenteComCriterios/{nomeDaTarefa}/false`
- **Método**: POST
- **Parâmetros URL**:
  - `{nomeDaTarefa}`: Nome codificado (URL-encoded) da tarefa
- **Body (Vazio)**: `{}`
- **Body (Com Filtro)**: `{"numeroProcesso": "0026889-76.2025.4.05.8200"}`
- **Resposta**:
  ```json
  {
    "sucesso": true,
    "total": 15,
    "entities": [
      {
        "idProcesso": 2427815,
        "numeroProcesso": "0026889-76.2025.4.05.8200",
        "idTaskInstance": 1870455664,
        "nomeTarefa": "Elaboração de decisão - Minutar",
        "tagsProcessoList": [...]
      }
    ]
  }
  ```
- **Campos Importantes**: `idProcesso`, `numeroProcesso`, `nomeTarefa`, `tagsProcessoList`, `idTaskInstance`
- **Casos de Uso**: Listar processos pendentes, buscar processo específico

#### 1.2. Buscar Informações de Processo Específico
- **Endpoint**: Mesmo do 1.1
- **Diferencial**: Body com `numeroProcesso` preenchido
- **Use Case**: Obter detalhes de um processo conhecido quando se tem o número CNJ

#### 1.3. Abrir Tela de Processo (Fluxo Composto)
**Passo 1 - Obter IDs**:
- Endpoint: Ver 1.1
- Extrair: `idProcesso`, `idTaskInstance`

**Passo 2 - Gerar Chave de Acesso**:
- **Endpoint**: `/gerarChaveAcessoProcesso/{idProcesso}`
- **Método**: GET
- **Resposta**: Texto plano (string da chave `ca`)

**Passo 3 - Montar URL Frontend**:
- **URL**: `https://pje1g.trf5.jus.br/pje/Processo/ConsultaProcesso/Detalhe/listAutosDigitais.seam?idProcesso={id}&ca={chave}&idTaskInstance={taskId}`

### 2. Etiquetas (Tags)

#### 2.1. Buscar/Listar Etiquetas
- **Endpoint**: `/etiquetas`
- **Método**: POST
- **Body**:
  ```json
  {
    "page": 0,
    "maxResults": 100,
    "tagsString": "termo de busca"
  }
  ```
- **Resposta**: `{"count": N, "entities": [{"id": X, "nomeTag": "..."}]}`
- **Use Case**: Obter ID de etiqueta pelo nome

#### 2.2. Criar Nova Etiqueta
- **Endpoint**: `/tags`
- **Método**: POST
- **Body**:
  ```json
  {
    "marcado": false,
    "possuiFilhos": false,
    "id": null,
    "nomeTag": "NOME_DA_ETIQUETA",
    "nomeTagCompleto": "NOME_DA_ETIQUETA",
    "pai": null
  }
  ```
- **Resposta**: Objeto da tag criada com novo `id`
- **CRÍTICO**: Requer header `X-pje-usuario-localizacao`

#### 2.3. Adicionar Etiqueta a Processo
- **Endpoint**: `/processoTags/inserir`
- **Método**: POST
- **Body**:
  ```json
  {
    "idProcesso": "2429886",  // STRING (crítico!)
    "tag": "NOME_DA_ETIQUETA"
  }
  ```
- **ATENÇÃO**: `idProcesso` DEVE ser STRING
- **Resposta**: ID da etiqueta adicionada

#### 2.4. Remover Etiqueta de Processo
- **Endpoint**: `/processoTags/remover`
- **Método**: POST
- **Body**:
  ```json
  {
    "idProcesso": 2349067,  // NÚMERO (crítico!)
    "idTag": 82308
  }
  ```
- **ATENÇÃO**: `idProcesso` DEVE ser NÚMERO (diferente do inserir!)
- **Mapeamento**: Usar `id` da lista como `idTag`

#### 2.5. Listar Processos por Etiqueta
- **Endpoint**: `/etiquetas/{idEtiqueta}/processos`
- **Método**: GET
- **Resposta**: Array de processos com detalhes completos

### 3. Tarefas

#### 3.1. Listar Tarefas Disponíveis
- **Endpoint**: `/tarefas`
- **Método**: POST
- **Body**:
  ```json
  {
    "numeroProcesso": "",
    "competencia": "",
    "etiquetas": []
  }
  ```
- **Resposta**: Array de tarefas com `id`, `nome`, `quantidadePendente`

## Particularidades Críticas

### Inconsistências da API
1. **Tipo de idProcesso**: STRING no inserir, NÚMERO no remover etiqueta
2. **Campo de Tag**: `id` na resposta → `idTag` no body de remoção
3. **Header obrigatório**: `X-pje-usuario-localizacao: 25555` para TODAS operações de escrita
4. **Credentials**: Sempre incluir `credentials: 'include'` no fetch

### Valores Estáticos Descobertos
- **Authorization**: `Basic MDUyMDk0Mzc0MDA6MTIzNDU=` (aparente autenticação de aplicação)
- **X-pje-usuario-localizacao**: `25555` (provavelmente ID da vara/localização)
- **X-pje-legacy-app**: `pje-trf5-1g`
