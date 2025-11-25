export class MensalidadeService {
  constructor(controller) {
    this.controller = controller
  }

  async atualizarValorMensalidade(event) {
  event.preventDefault()
  
  const valor = this.controller.valorMensalidadeTarget.value
  const diaVencimento = this.controller.diaVencimentoTarget.value
  
  if (!valor || parseFloat(valor) <= 0) {
    this.controller.mostrarMensagem('Por favor, insira um valor válido', 'error')
    return
  }

  if (!diaVencimento || diaVencimento < 1 || diaVencimento > 31) {
    this.controller.mostrarMensagem('Dia de vencimento deve ser entre 1 e 31', 'error')
    return
  }

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

    const data = await response.json()
    
    if (data.success) {
      this.controller.mostrarMensagem(data.mensagem, 'success')
      setTimeout(() => location.reload(), 1500)
    } else {
      this.controller.mostrarMensagem(data.mensagem, 'error')
    }
  } catch (error) {
    console.error('Erro:', error)
    this.controller.mostrarMensagem('Erro ao atualizar configuração', 'error')
  }
}

  async abrirModal(event) {
  const alunoId = event.currentTarget.dataset.alunoId
  const alunoNome = event.currentTarget.dataset.alunoNome
  
  this.controller.alunoAtual = alunoId
  this.controller.modalAlunoNomeTarget.textContent = alunoNome
  
  try {
    const response = await fetch(`/financeiro/info_mensalidade_aluno/${alunoId}`)
    const data = await response.json()
    
    this.controller.valorTotalMensalidadeTarget.value = data.valor_total
    this.controller.valorPagoMensalidadeTarget.value = data.valor_pago
    
    this.atualizarStatusVencimento(data)
    this.calcularPendente()
    
  } catch (error) {
    console.error("Erro ao buscar info de mensalidade:", error)
    this.controller.mostrarMensagem('Erro ao carregar informações', 'error')
  }
  
  this.controller.modalMensalidadeTarget.classList.remove('hidden')
}

atualizarStatusVencimento(data) {
  const statusContainer = this.controller.statusPagamentoContainerTarget
  const statusLabel = this.controller.statusPagamentoLabelTarget

  if (data.atrasado) {
    statusContainer.className = 'p-4 rounded-lg bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800'
    statusLabel.innerHTML = `
      <i class="fas fa-exclamation-triangle text-red-600 dark:text-red-400"></i>
      <div>
        <div class="font-semibold text-red-800 dark:text-red-300">Pagamento Atrasado</div>
        <div class="text-sm text-red-600 dark:text-red-400">Venceu em ${data.data_vencimento} (${data.dias_atraso} ${data.dias_atraso === 1 ? 'dia' : 'dias'} de atraso)</div>
      </div>
    `
  } else if (data.status === 'Pago') {
    statusContainer.className = 'p-4 rounded-lg bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800'
    statusLabel.innerHTML = `
      <i class="fas fa-check-circle text-green-600 dark:text-green-400"></i>
      <div>
        <div class="font-semibold text-green-800 dark:text-green-300">Mensalidade Quitada</div>
        <div class="text-sm text-green-600 dark:text-green-400">Pagamento realizado</div>
      </div>
    `
  } else {
  statusContainer.className =
    'p-4 rounded-lg bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800'

  let vencimentoHTML = ""

  if (data.data_vencimento) {
    vencimentoHTML = `
      <div class="text-sm text-blue-600 dark:text-blue-400">
        Vencimento: ${data.data_vencimento}
      </div>
    `
  }

  statusLabel.innerHTML = `
    <i class="fas fa-calendar-day text-blue-600 dark:text-blue-400"></i>
    <div>
      <div class="font-semibold text-blue-800 dark:text-blue-300">Pagamento Pendente</div>
      ${vencimentoHTML}
    </div>
  `
}

}

calcularPendente() {
  const total = parseFloat(this.controller.valorTotalMensalidadeTarget.value) || 0
  const pago = parseFloat(this.controller.valorPagoMensalidadeTarget.value) || 0
  const diferenca = total - pago
  
  const container = this.controller.valorPendenteContainerTarget
  const valor = this.controller.valorPendenteMensalidadeTarget
  
  if (diferenca <= 0) {
    container.className = 'p-3 rounded-lg bg-green-50 dark:bg-green-900/20'
    valor.textContent = 'Quitado'
    valor.className = 'text-lg font-bold text-green-600 dark:text-green-400'
  } else if (pago > 0) {
    container.className = 'p-3 rounded-lg bg-yellow-50 dark:bg-yellow-900/20'
    valor.textContent = this.controller.formatarMoeda(diferenca)
    valor.className = 'text-lg font-bold text-yellow-600 dark:text-yellow-400'
  } else {
    container.className = 'p-3 rounded-lg bg-gray-50 dark:bg-[#111111]'
    valor.textContent = this.controller.formatarMoeda(diferenca)
    valor.className = 'text-lg font-bold text-gray-900 dark:text-[#E5E5E5]'
  }
}

  async confirmarPagamento() {
    const caixaId = this.controller.caixaMensalidadeTarget.value
    const metodo = this.controller.metodoMensalidadeTarget.value
    const valorTotal = this.controller.valorTotalMensalidadeTarget.value
    const valorPago = this.controller.valorPagoMensalidadeTarget.value

    if (!caixaId) {
      this.controller.mostrarMensagem("Por favor, selecione um caixa.", "error")
      return
    }

    if (!valorPago || parseFloat(valorPago) <= 0) {
      this.controller.mostrarMensagem("Por favor, insira o valor pago.", "error")
      return
    }

    try {
      const response = await fetch('/financeiro/registrar_pagamento_mensalidade', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.controller.getCSRFToken()
        },
        body: JSON.stringify({
          aluno_id: this.controller.alunoAtual,
          caixa_id: caixaId,
          metodo: metodo,
          valor_total: valorTotal,
          valor_pago: valorPago
        })
      })

      const data = await response.json()

      if (data.success) {
        this.controller.mostrarMensagem(data.message, "success")
        await this.controller.atualizarExtrato()
        setTimeout(() => {
          this.fecharModal()
          window.location.reload()
        }, 1000)
      } else {
        this.controller.mostrarMensagem(data.errors?.join(', ') || "Erro ao registrar mensalidade.", "error")
      }
    } catch (error) {
      console.error("Erro:", error)
      this.controller.mostrarMensagem("Erro ao registrar mensalidade.", "error")
    }
  }

  fecharModal() {
    this.controller.modalMensalidadeTarget.classList.add('hidden')
    this.controller.alunoAtual = null
  }
}