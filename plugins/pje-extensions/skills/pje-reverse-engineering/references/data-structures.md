# Estruturas de Dados - PJe TRF5

## Visão Geral
Este documento preserva dumps JSON reais de estruturas de dados do PJe, obtidos através de engenharia reversa. Servem como referência autoritativa para desenvolvimento.

## 1. Fluxo Processual

### 1.1. Propósito
Mapear todas as tarefas do sistema e suas transições possíveis.

### 1.2. Estrutura do Objeto

```json
{
  "task": "Nome completo da tarefa no PJe",
  "transitions": [
    {
      "type": "button | select_option",
      "label": "Texto exibido para o usuário",
      "id": "ID do elemento HTML (pode ser vazio)",
      "probable_targets": ["Tarefa(s) de destino"]
    }
  ]
}
```

### 1.3. Campos Detalhados

**task** (string):
- Nome completo da tarefa como aparece no PJe
- Inclui prefixo de fluxo (ex: "Fluxo Inicial - ", "Migração de processos - ")
- Exemplo: `"Fluxo Inicial - Arquivamento - Fechar expediente"`

**transitions** (array):
- Lista de todas ações/movimentações possíveis da tarefa
- Cada transição é um objeto com:

**type** (string):
- `"button"`: Ação via botão direto
- `"select_option"`: Opção dentro de um combobox/select

**label** (string):
- Texto exibido no botão ou opção
- Usado para matching em automações
- Exemplos: `"Salvar"`, `"Arquivar"`, `"Minutar sentença"`

**id** (string):
- ID HTML do elemento
- Pode ser vazio para select_options (ID está no select, não na option)
- Padrão JSF: `taskInstanceForm:j_id142:0:j_id143`

**probable_targets** (array):
- Lista de tarefas para onde essa transição leva
- Pode estar vazio (desconhecido ou complexo)
- Exemplo: `["Fluxo Inicial - [JEF] Audiência - Elaborar ata"]`

### 1.4. Exemplo Completo

```json
{
  "task": "Migração de processos - Audiência - Aguardar",
  "transitions": [
    {
      "type": "button",
      "label": "Designar nova audiência",
      "id": "taskInstanceForm:Processo_Fluxo_abaDesignarAudiencia-2180140934:btDesignarAudiencia",
      "probable_targets": []
    },
    {
      "type": "button",
      "label": "Selecione uma próxima ação ao lado",
      "id": "taskInstanceForm:transicaoSaidaBtn",
      "probable_targets": []
    },
    {
      "type": "select_option",
      "menu_label": "Próxima ação",
      "label": "Elaborar ata",
      "id": "",
      "probable_targets": [
        "Fluxo Inicial - [JEF] Audiência - Elaborar ata"
      ]
    }
  ]
}
```

## 2. Mapa de Tarefas

### 2.1. Propósito
Snapshot detalhado da estrutura HTML de cada tarefa, incluindo todos botões, selects, inputs e seus estados.

### 2.2. Estrutura do Objeto

```json
{
  "tarefa": "Nome simplificado da tarefa",
  "processo_amostra": "Número do processo usado como amostra",
  "dados": {
    "processo": "N/A",
    "tarefa": "Nome completo da tarefa",
    "url": "URL da página movimentar.seam com parâmetros",
    "timestamp": "ISO timestamp da captura",
    "estrutura_detalhada": {
      "botoes": [...],
      "selects": [...],
      "inputs": [...],
      "textos_relevantes": [...]
    },
    "snapshot_ia": "Representação textual para LLMs"
  }
}
```

### 2.3. Campos Detalhados

**tarefa** (string):
- Nome simplificado para identificação rápida
- Exemplo: `"Arquivamento - Fechar expediente"`

**processo_amostra** (string):
- Número CNJ do processo usado na captura
- Exemplo: `"0044588-80.2025.4.05.8200"`

**dados.url** (string):
- URL completa da página `movimentar.seam`
- Inclui `newTaskId`, `idProcesso`, `iframe=false`
- Útil para reprodução

**dados.timestamp** (string):
- Data/hora ISO 8601 da captura
- Permite rastrear versão do PJe

**estrutura_detalhada.botoes** (array):
```json
{
  "texto": "Texto do botão",
  "id": "ID HTML completo",
  "path": "Caminho CSS completo até o elemento",
  "disabled": true/false
}
```

**estrutura_detalhada.selects** (array):
```json
{
  "id": "ID do select (pode ser vazio)",
  "label_proximo": "Label associado (ex: 'Próxima ação')",
  "opcoes": ["Opção 1", "Opção 2", ...]
}
```

**snapshot_ia** (string):
- Representação textual formatada para consumo por LLMs
- Facilita análise por IA

### 2.4. Exemplo Completo

```json
{
  "tarefa": "Audiência - Aguardar",
  "processo_amostra": "0802947-79.2025.4.05.8200",
  "dados": {
    "processo": "N/A",
    "tarefa": "Migração de processos - Audiência - Aguardar",
    "url": "https://pje1g.trf5.jus.br/pje/Processo/movimentar.seam?newTaskId=2180140934&idProcesso=2256063&iframe=false",
    "timestamp": "2025-12-21T19:01:58.898Z",
    "estrutura_detalhada": {
      "botoes": [
        {
          "texto": "Designar nova audiência",
          "id": "taskInstanceForm:Processo_Fluxo_abaDesignarAudiencia-2180140934:btDesignarAudiencia",
          "path": "body > div#j_id66 > ... > input#taskInstanceForm:Processo_Fluxo_abaDesignarAudiencia-2180140934:btDesignarAudiencia",
          "disabled": false
        },
        {
          "texto": "Selecione uma próxima ação ao lado",
          "id": "taskInstanceForm:transicaoSaidaBtn",
          "path": "body > div#j_id66 > ... > input#taskInstanceForm:transicaoSaidaBtn",
          "disabled": true
        }
      ],
      "selects": [
        {
          "id": "",
          "label_proximo": "Próxima ação",
          "opcoes": [
            "Cancelar audiências automaticamente",
            "Designar audiência",
            "Elaborar ata",
            "Encaminhar para análise da secretaria",
            "Intimar da designação de audiência"
          ]
        }
      ]
    }
  }
}
```

## 3. Estrutura de Resposta API (Processo)

### 3.1. Estrutura JSON

```json
{
  "sucesso": true,
  "mensagem": null,
  "total": 1,
  "entities": [
    {
      "idTaskInstance": 1870455664,
      "poloAtivo": "SINDICATO DOS POLICIAIS FEDERAIS...",
      "poloPassivo": "FAZENDA NACIONAL",
      "idProcesso": 2427815,
      "numeroProcesso": "0026889-76.2025.4.05.8200",
      "classeJudicial": "PetCiv",
      "idOrgaoJulgador": 66,
      "orgaoJulgador": "3ª Vara Federal PB",
      "dataChegada": 1755274280571,
      "conferido": false,
      "nomeTarefa": "Elaboração de decisão - Minutar",
      "sigiloso": false,
      "prioridade": true,
      "tagsProcessoList": [
        {
          "id": 137077,
          "nomeTag": "1º GRAU",
          "nomeTagCompleto": "1º GRAU",
          "idUsuario": 0,
          "idProcesso": 2427815,
          "idProcessoTag": 141484043
        }
      ]
    }
  ]
}
```

## 4. Referências Cruzadas

- **Automação**: Ver `automation-workflow.md` para uso destes dumps
- **API Endpoints**: Ver `api-endpoints.md` para estrutura de resposta de processos
