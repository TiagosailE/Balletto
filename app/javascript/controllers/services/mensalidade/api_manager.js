export class MensalidadeAPIManager {
  constructor(controller) {
    this.controller = controller
  }

  async buscarInfoMensalidade(alunoId) {
    try {
      const response = await fetch(`/financeiro/info_mensalidade_aluno/${alunoId}`)
      return await response.json()
    } catch (error) {
      console.error("Erro ao buscar info de mensalidade:", error)
      throw error
    }
  }

  async atualizarValorMensalidade(valor, diaVencimento) {
    try {
      const response = await fetch('/financeiro/atualizar_valor_mensalidade', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.controller.getCSRFToken()
        },
        body: JSON.stringify({ 
          valor: parseFloat(valor),
          dia_vencimento: parseInt(diaVencimento)
        })
      })

      return await response.json()
    } catch (error) {
      console.error('Erro:', error)
      throw error
    }
  }

  async registrarPagamento(dados, modoEdicao, pagamentoId) {
    const endpoint = modoEdicao 
      ? '/financeiro/editar_pagamento_mensalidade'
      : '/financeiro/registrar_pagamento_mensalidade'

    const body = {
      aluno_id: dados.alunoId,
      caixa_id: dados.caixaId,
      metodo: dados.metodo,
      valor_total: dados.valorTotal,
      valor_pago: dados.valorPago
    }

    if (modoEdicao && pagamentoId) {
      body.pagamento_id = pagamentoId
    }

    try {
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.controller.getCSRFToken()
        },
        body: JSON.stringify(body)
      })

      return await response.json()
    } catch (error) {
      console.error("Erro:", error)
      throw error
    }
  }
}