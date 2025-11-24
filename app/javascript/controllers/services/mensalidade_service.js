export class MensalidadeService {
  constructor(controller) {
    this.controller = controller
  }

  async atualizarValorMensalidade(event) {
    const button = event.currentTarget
    const valor = this.controller.valorMensalidadeTarget.value

    if (!valor || parseFloat(valor) < 0) {
      this.controller.mostrarMensagem("Por favor, insira um valor válido.", "error")
      return
    }

    try {
      button.disabled = true
      button.innerHTML = '<i class="fas fa-spinner fa-spin"></i>'

      const response = await fetch('/financeiro/atualizar_valor_mensalidade', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.controller.getCSRFToken()
        },
        body: JSON.stringify({ valor: valor })
      })

      const data = await response.json()

      if (data.success) {
        this.controller.mostrarMensagem("Valor da mensalidade atualizado!", "success")

        if (this.controller.hasValorTotalMensalidadeTarget) {
          this.controller.valorTotalMensalidadeTarget.value = valor
          this.calcularPendente()
        }
      } else {
        this.controller.mostrarMensagem("Erro ao atualizar valor.", "error")
      }
    } catch (error) {
      console.error("Erro:", error)
      this.controller.mostrarMensagem("Erro ao atualizar valor da mensalidade.", "error")
    } finally {
      button.disabled = false
      button.innerHTML = 'Atualizar'
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
      
      if (data.quitado) {
        this.renderizarMensalidadeQuitada(data)
      } else {
        this.renderizarFormularioPagamento(data)
      }
    } catch (error) {
      console.error("Erro ao buscar info de mensalidade:", error)
      this.controller.valorPagoMensalidadeTarget.value = ''
      this.calcularPendente()
    }
    
    this.controller.modalMensalidadeTarget.classList.remove('hidden')
  }

  renderizarMensalidadeQuitada(data) {
    const form = this.controller.modalMensalidadeTarget.querySelector('.modal-content')
    form.innerHTML = `
      <div class="py-12 text-center">
        <div class="w-20 h-20 bg-green-100 dark:bg-green-900/30 rounded-full flex items-center justify-center mx-auto mb-4">
          <i class="fas fa-check-circle text-4xl text-green-600 dark:text-green-400"></i>
        </div>
        <h3 class="text-2xl font-bold text-green-600 dark:text-green-400 mb-2">Mensalidade Quitada!</h3>
        <p class="text-gray-600 dark:text-gray-400 mb-4">
          Pagamento realizado em ${data.data_pagamento}
        </p>
        <div class="bg-green-50 dark:bg-green-900/20 rounded-lg p-4 inline-block">
          <p class="text-sm text-gray-600 dark:text-gray-400">Valor pago</p>
          <p class="text-2xl font-bold text-green-600 dark:text-green-400">${this.controller.formatarMoeda(data.valor_pago)}</p>
        </div>
        <div class="mt-6">
          <button 
            data-action="click->financeiro#fecharModalMensalidade"
            class="w-full px-6 py-3 bg-gray-200 dark:bg-[#2E2E2E] text-gray-700 dark:text-gray-300 font-semibold rounded-lg hover:bg-gray-300 dark:hover:bg-[#3E3E3E] transition-colors">
            Fechar
          </button>
        </div>
      </div>
    `
  }

  renderizarFormularioPagamento(data) {
    const avisoContainer = this.controller.modalMensalidadeTarget.querySelector('.aviso-pagamento')
    if (avisoContainer) {
      if (data.pagamento_existente) {
        avisoContainer.innerHTML = `
          <div class="p-4 rounded-lg bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 mb-4">
            <div class="flex items-center gap-2 text-yellow-800 dark:text-yellow-300">
              <i class="fas fa-info-circle text-xl"></i>
              <div>
                <p class="font-semibold">Pagamento Parcial Registrado</p>
                <p class="text-sm">Já pago: ${this.controller.formatarMoeda(data.valor_ja_pago)} | Falta: ${this.controller.formatarMoeda(data.valor_pendente)}</p>
              </div>
            </div>
          </div>
        `
        avisoContainer.classList.remove('hidden')
      } else {
        avisoContainer.innerHTML = ''
        avisoContainer.classList.add('hidden')
      }
    }
    
    this.controller.valorTotalMensalidadeTarget.value = data.valor_total
    this.controller.valorPagoMensalidadeTarget.value = ''
    this.calcularPendente()
  }

  calcularPendente() {
    const total = parseFloat(this.controller.valorTotalMensalidadeTarget.value) || 0
    const pago = parseFloat(this.controller.valorPagoMensalidadeTarget.value) || 0
    const diferenca = total - pago
    
    const container = this.controller.element.querySelector('[data-financeiro-target="statusPagamentoContainer"]')
    const label = this.controller.element.querySelector('[data-financeiro-target="statusPagamentoLabel"]')
    const valor = this.controller.valorPendenteMensalidadeTarget
    
    if (diferenca < 0) {
      const troco = Math.abs(diferenca)
      label.textContent = 'Troco:'
      valor.textContent = this.controller.formatarMoeda(troco)
      valor.className = 'text-lg font-bold text-blue-600 dark:text-blue-400'
      container.className = 'p-3 rounded-lg bg-blue-50 dark:bg-blue-900/20'
    } else if (diferenca === 0) {
      label.textContent = 'Status:'
      valor.textContent = 'Quitado'
      valor.className = 'text-lg font-bold text-green-600 dark:text-green-400'
      container.className = 'p-3 rounded-lg bg-green-50 dark:bg-green-900/20'
    } else if (pago > 0) {
      label.textContent = 'Valor Pendente:'
      valor.textContent = this.controller.formatarMoeda(diferenca)
      valor.className = 'text-lg font-bold text-yellow-600 dark:text-yellow-400'
      container.className = 'p-3 rounded-lg bg-yellow-50 dark:bg-yellow-900/20'
    } else {
      label.textContent = 'Valor Pendente:'
      valor.textContent = this.controller.formatarMoeda(diferenca)
      valor.className = 'text-lg font-bold text-red-600 dark:text-red-400'
      container.className = 'p-3 rounded-lg bg-red-50 dark:bg-red-900/20'
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