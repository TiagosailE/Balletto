export class MensalidadeCampoManager {
    constructor(controller) {
    this.controller = controller
  }

  configurarModoVisualizacao(data) {
    const campoValorPago = this.controller.valorPagoMensalidadeTarget
    
    campoValorPago.value = data.valor_pago
    campoValorPago.disabled = true
    campoValorPago.readOnly = true
    
    this.esconderCampoValorPagarAgora()
    this.desabilitarCamposGerais()
  }

  configurarModoRegistro(data) {
    const campoValorPago = this.controller.valorPagoMensalidadeTarget
    
    campoValorPago.value = data.valor_pago
    campoValorPago.disabled = true
    campoValorPago.readOnly = true
    if (data.valor_pago > 0) {
      this.mostrarCampoValorJaPago()
    } else {
      this.esconderCampoValorJaPago()
    }
    
    this.mostrarCampoValorPagarAgora()
    this.habilitarCamposGerais()
    this.restaurarLabelOriginal()
  }

  habilitarEdicao() {
    const campoValorPago = this.controller.valorPagoMensalidadeTarget
    
    campoValorPago.disabled = false
    campoValorPago.readOnly = false
    campoValorPago.classList.remove('bg-gray-100', 'text-gray-600', 'cursor-not-allowed')
    campoValorPago.classList.remove('dark:bg-[#0A0A0A]', 'dark:text-gray-400')
    campoValorPago.classList.add('bg-white', 'text-gray-900')
    campoValorPago.classList.add('dark:bg-[#0A0A0A]', 'dark:text-[#E5E5E5]')
    
    this.esconderCampoValorPagarAgora()
    this.habilitarCamposGerais()
    this.atualizarLabelEdicao()
  }

  esconderCampoValorPagarAgora() {
    const campoValorPagarAgora = document.querySelector('[data-mensalidade-target="valorPagarAgora"]')
    if (campoValorPagarAgora && campoValorPagarAgora.parentElement) {
      campoValorPagarAgora.value = ''
      campoValorPagarAgora.disabled = true
      campoValorPagarAgora.parentElement.style.display = 'none'
    }
  }

  mostrarCampoValorPagarAgora() {
    const campoValorPagarAgora = document.querySelector('[data-mensalidade-target="valorPagarAgora"]')
    if (campoValorPagarAgora && campoValorPagarAgora.parentElement) {
      campoValorPagarAgora.value = ''
      campoValorPagarAgora.disabled = false
      campoValorPagarAgora.parentElement.style.display = 'block'
    }
  }

  esconderCampoValorJaPago() {
    const campoValorPago = this.controller.valorPagoMensalidadeTarget
    if (campoValorPago && campoValorPago.parentElement) {
      campoValorPago.parentElement.style.display = 'none'
    }
  }

  mostrarCampoValorJaPago() {
    const campoValorPago = this.controller.valorPagoMensalidadeTarget
    if (campoValorPago && campoValorPago.parentElement) {
      campoValorPago.parentElement.style.display = 'block'
    }
  }

  desabilitarCamposGerais() {
    this.controller.valorTotalMensalidadeTarget.disabled = true
    this.controller.caixaMensalidadeTarget.disabled = true
    this.controller.metodoMensalidadeTarget.disabled = true
  }

  habilitarCamposGerais() {
    this.controller.valorTotalMensalidadeTarget.disabled = false
    this.controller.caixaMensalidadeTarget.disabled = false
    this.controller.metodoMensalidadeTarget.disabled = false
  }

  atualizarLabelEdicao() {
    const campoValorPago = this.controller.valorPagoMensalidadeTarget
    const labelValorPago = campoValorPago.closest('div')?.querySelector('label')
    
    if (labelValorPago) {
      labelValorPago.innerHTML = `
        Valor Pago Total
        <span class="text-xs text-yellow-600 dark:text-yellow-400 ml-2">
          (Editando - ajuste o valor total pago)
        </span>
      `
    }
  }

  restaurarLabelOriginal() {
    const campoValorPago = this.controller.valorPagoMensalidadeTarget
    const labelValorPago = campoValorPago.closest('div')?.querySelector('label')
    
    if (labelValorPago) {
      labelValorPago.innerHTML = 'Valor Já Pago'
    }
  }
}