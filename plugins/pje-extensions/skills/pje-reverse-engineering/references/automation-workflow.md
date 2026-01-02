# Automação de Fluxo de Trabalho - PJe TRF5

## Visão Geral
Este documento detalha as estratégias para automação da movimentação de tarefas no PJe, incluindo deep linking, identificação de controles e execução parametrizada.

## 1. Conceitos Fundamentais

### 1.1. Terminologia

**Abrir Tarefa**:
- Acessar página `movimentar.seam`
- Carrega editor de minutas e dados do processo
- Habilita controles de movimentação

**Controles de Movimentação**:
- Elementos de interface (botões, selects) no rodapé
- Permitem despachar processo para próxima fase
- Dinâmicos: variam por tarefa/fluxo

**Deep Linking**:
- Técnica de abrir páginas com parâmetros específicos
- Usado para garantir visibilidade de controles

### 1.2. URL de Movimentação

**Estrutura**:
```
https://pje1g.trf5.jus.br/pje/Processo/movimentar.seam?newTaskId={taskId}&idProcesso={processoId}&iframe=false
```

**Parâmetros**:
- `newTaskId`: ID da instância da tarefa
- `idProcesso`: ID do processo
- `iframe=false`: **CRÍTICO** - força exibição de controles de movimentação no rodapé

**Importância do iframe=false**:
- Sem ele, página carrega em modo "embedded"
- Controles de movimentação ficam ocultos/inacessíveis
- Deep linking garante UI completa

## 2. Arquitetura do Motor de Automação

### 2.1. Princípio: Executor Parametrizado

**Conceito**:
- Automação NÃO decide destino
- Recebe instrução (string) como parâmetro
- Executa ação correspondente

**Vantagem**:
- Agnóstico ao fluxo específico
- Funciona com centenas de variações de tarefa
- Facilita manutenção (lógica única)

### 2.2. Padrões de Interface Identificados

#### Padrão A: Seleção + Confirmação
**Estrutura**:
1. Select/Combobox com label "Próxima ação"
2. Opções dentro do select
3. Botão de confirmação (ex: "IR", "OK") habilitado após seleção

**Exemplo**:
```html
<label>Próxima ação</label>
<select id="transicaoSaida">
  <option>Minutar Sentença</option>
  <option>Conclusão para decisão</option>
  <option>Arquivar</option>
</select>
<button id="transicaoSaidaBtn" disabled>IR</button>
```

#### Padrão B: Botão Direto
**Estrutura**:
- Botão com texto da ação (ex: "ASSINAR", "ARQUIVAR")
- Ação executada diretamente ao clicar

**Exemplo**:
```html
<button id="taskInstanceForm:j_id142:0:j_id143">Assinar</button>
<button id="taskInstanceForm:j_id142:1:j_id143">Encaminhar para análise</button>
```

### 2.3. Algoritmo de Detecção

```javascript
function executarMovimentacao(instrucao) {
  // 1. Normalizar instrução (lowercase, trim)
  const instrucaoNormalizada = instrucao.toLowerCase().trim();

  // 2. Tentar Padrão B primeiro (mais direto)
  const botoes = document.querySelectorAll('button, input[type="submit"]');
  for (const botao of botoes) {
    const textoBotao = botao.textContent.toLowerCase().trim();
    if (textoBotao.includes(instrucaoNormalizada)) {
      botao.click();
      return { sucesso: true, metodo: 'botao-direto' };
    }
  }

  // 3. Tentar Padrão A (select + confirmação)
  const selects = document.querySelectorAll('select');
  for (const select of selects) {
    // Verificar se é o select de "Próxima ação"
    const label = select.previousElementSibling;
    if (label && label.textContent.includes('Próxima ação')) {
      // Buscar opção correspondente
      const opcoes = select.querySelectorAll('option');
      for (const opcao of opcoes) {
        const textoOpcao = opcao.textContent.toLowerCase().trim();
        if (textoOpcao.includes(instrucaoNormalizada)) {
          // Selecionar e aguardar botão
          select.value = opcao.value;
          select.dispatchEvent(new Event('change', { bubbles: true }));

          // Aguardar habilitação do botão de confirmação
          aguardarBotaoConfirmacao().then(botao => {
            botao.click();
          });
          return { sucesso: true, metodo: 'select-confirmacao' };
        }
      }
    }
  }

  return { sucesso: false, erro: 'Instrução não encontrada' };
}
```

## 3. Dinamicidade e Mapeamento em Tempo Real

### 3.1. Princípio da Agnósticidade

**Problema**:
- PJe possui centenas de fluxos diferentes
- Opções de movimentação variam por vara, tipo de processo, fase
- Hardcodar seria impossível/frágil

**Solução**:
- Automação descobre opções em tempo real
- Não depende de mapeamento prévio exaustivo
- Usa heurísticas de busca (texto, proximidade)

### 3.2. Validação de Instrução

```javascript
function validarInstrucao(instrucao) {
  const controles = mapearControlesDisponiveis();

  // Verificar em botões diretos
  const botaoEncontrado = controles.botoesDiretos.some(btn =>
    btn.texto.toLowerCase().includes(instrucao.toLowerCase())
  );

  if (botaoEncontrado) {
    return { valida: true, tipo: 'botao' };
  }

  // Verificar em selects
  const selectComOpcao = controles.selectsComOpcoes.find(sel =>
    sel.opcoes.some(opt => opt.toLowerCase().includes(instrucao.toLowerCase()))
  );

  if (selectComOpcao) {
    return { valida: true, tipo: 'select', select: selectComOpcao };
  }

  return { valida: false, erro: 'Instrução não disponível nesta tarefa' };
}
```

## 4. Integração com Extensões Chrome

### 4.1. Content Script

```javascript
// content.js
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'executar-movimentacao') {
    const resultado = executarMovimentacao(request.instrucao);
    sendResponse(resultado);
  }

  if (request.action === 'mapear-controles') {
    const controles = mapearControlesDisponiveis();
    sendResponse(controles);
  }

  return true; // Async response
});
```

### 4.2. Background Orchestration

```javascript
// background.js
async function moverProcesso(tabId, instrucao) {
  // 1. Validar se controles estão disponíveis
  const controles = await chrome.tabs.sendMessage(tabId, {
    action: 'mapear-controles'
  });

  // 2. Executar movimentação
  const resultado = await chrome.tabs.sendMessage(tabId, {
    action: 'executar-movimentacao',
    instrucao: instrucao
  });

  return resultado;
}
```

## 5. Referências Cruzadas

- **Autenticação**: Ver `authentication.md` para headers necessários
- **Estruturas de Dados**: Consultar dumps JSON incluídos em `data-structures.md`
