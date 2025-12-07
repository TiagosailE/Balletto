export class MensalidadeUIManager {
  constructor(controller) {
    this.controller = controller
  }

  atualizarStatusVencimento(data) {
    const statusContainer = this.controller.statusPagamentoContainerTarget
    const statusLabel = this.controller.statusPagamentoLabelTarget

    if (data.quitado) {
      this.mostrarStatusQuitado()
    } else if (data.atrasado) {
      this.mostrarStatusAtrasado(data)
    } else {
      this.mostrarStatusPendente(data)
    }
  }

  mostrarStatusQuitado() {
    const statusContainer = this.controller.statusPagamentoContainerTarget
    const statusLabel = this.controller.statusPagamentoLabelTarget
    
    statusContainer.className = 'p-4 rounded-lg bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800'
    statusLabel.innerHTML = `
      <i class="fas fa-check-circle text-green-600 dark:text-green-400"></i>
      <div>
        <div class="font-semibold text-green-800 dark:text-green-300">Mensalidade Quitada</div>
        <div class="text-sm text-green-600 dark:text-green-400">Pagamento realizado</div>
      </div>
    `
  }

  mostrarStatusAtrasado(data) {
    const statusContainer = this.controller.statusPagamentoContainerTarget
    const statusLabel = this.controller.statusPagamentoLabelTarget
    
    statusContainer.className = 'p-4 rounded-lg bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800'
    statusLabel.innerHTML = `
      <i class="fas fa-exclamation-triangle text-red-600 dark:text-red-400"></i>
      <div>
        <div class="font-semibold text-red-800 dark:text-red-300">Pagamento Atrasado</div>
        <div class="text-sm text-red-600 dark:text-red-400">Venceu em ${data.data_vencimento} (${data.dias_atraso} ${data.dias_atraso === 1 ? 'dia' : 'dias'} de atraso)</div>
      </div>
    `
  }

  mostrarStatusPendente(data) {
    const statusContainer = this.controller.statusPagamentoContainerTarget
    const statusLabel = this.controller.statusPagamentoLabelTarget
    
    statusContainer.className = 'p-4 rounded-lg bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800'
    statusLabel.innerHTML = `
      <i class="fas fa-calendar-day text-blue-600 dark:text-blue-400"></i>
      <div>
        <div class="font-semibold text-blue-800 dark:text-blue-300">Pagamento Pendente</div>
        ${data.data_vencimento ? `<div class="text-sm text-blue-600 dark:text-blue-400">Vencimento: ${data.data_vencimento}</div>` : ''}
      </div>
    `
  }

  calcularPendente(modoEdicao) {
    const total = parseFloat(this.controller.valorTotalMensalidadeTarget.value) || 0
    let valorPagoTotal = 0
    
    if (modoEdicao) {
      valorPagoTotal = parseFloat(this.controller.valorPagoMensalidadeTarget.value) || 0
    } else {
      const valorJaPago = parseFloat(this.controller.valorPagoMensalidadeTarget.value) || 0
      const campoValorPagarAgora = document.querySelector('[data-mensalidade-target="valorPagarAgora"]')
      const valorPagarAgora = campoValorPagarAgora ? (parseFloat(campoValorPagarAgora.value) || 0) : 0
      valorPagoTotal = valorJaPago + valorPagarAgora
    }
    
    const diferenca = total - valorPagoTotal
    
    const container = this.controller.valorPendenteContainerTarget
    const valor = this.controller.valorPendenteMensalidadeTarget
    
    if (diferenca <= 0) {
      container.className = 'p-3 rounded-lg bg-green-50 dark:bg-green-900/20'
      valor.textContent = 'Quitado'
      valor.className = 'text-lg font-bold text-green-600 dark:text-green-400'
    } else if (valorPagoTotal > 0) {
      container.className = 'p-3 rounded-lg bg-yellow-50 dark:bg-yellow-900/20'
      valor.textContent = this.controller.formatarMoeda(diferenca)
      valor.className = 'text-lg font-bold text-yellow-600 dark:text-yellow-400'
    } else {
      container.className = 'p-3 rounded-lg bg-gray-50 dark:bg-[#111111]'
      valor.textContent = this.controller.formatarMoeda(diferenca)
      valor.className = 'text-lg font-bold text-gray-900 dark:text-[#E5E5E5]'
    }
  }

  atualizarBotoesFooter(quitado) {
    const footerDiv = document.querySelector('[data-financeiro-target="modalMensalidade"] .flex.gap-3.p-6')
    
    if (!footerDiv) return
    
    if (quitado) {
      footerDiv.innerHTML = `
        <button 
          data-action="click->financeiro#fecharModalMensalidade"
          class="flex-1 px-4 py-2 border border-gray-300 dark:border-[#2E2E2E] text-gray-700 dark:text-gray-300 font-semibold rounded-lg hover:bg-gray-50 dark:hover:bg-[#1A1A1A] transition-colors">
          Fechar
        </button>
        <button 
          data-action="click->financeiro#habilitarEdicaoMensalidade"
          class="flex-1 px-4 py-2 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700 transition-colors">
          <i class="fas fa-edit mr-2"></i>Editar Pagamento
        </button>
      `
    } else {
      footerDiv.innerHTML = `
        <button 
          data-action="click->financeiro#fecharModalMensalidade"
          class="flex-1 px-4 py-2 border border-gray-300 dark:border-[#2E2E2E] text-gray-700 dark:text-gray-300 font-semibold rounded-lg hover:bg-gray-50 dark:hover:bg-[#1A1A1A] transition-colors">
          Cancelar
        </button>
        <button 
          data-action="click->financeiro#confirmarPagamentoMensalidade"
          class="flex-1 px-4 py-2 bg-green-600 text-white font-semibold rounded-lg hover:bg-green-700 transition-colors">
          Confirmar Pagamento
        </button>
      `
    }
  }

  atualizarBotoesEdicao() {
    const footerDiv = document.querySelector('[data-financeiro-target="modalMensalidade"] .flex.gap-3.p-6')
    if (footerDiv) {
      footerDiv.innerHTML = `
        <button 
          data-action="click->financeiro#fecharModalMensalidade"
          class="flex-1 px-4 py-2 border border-gray-300 dark:border-[#2E2E2E] text-gray-700 dark:text-gray-300 font-semibold rounded-lg hover:bg-gray-50 dark:hover:bg-[#1A1A1A] transition-colors">
          Cancelar
        </button>
        <button 
          data-action="click->financeiro#confirmarPagamentoMensalidade"
          class="flex-1 px-4 py-2 bg-green-600 text-white font-semibold rounded-lg hover:bg-green-700 transition-colors">
          <i class="fas fa-save mr-2"></i>Salvar Alterações
        </button>
      `
    }
  }
}