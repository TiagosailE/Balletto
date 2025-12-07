import { MensalidadeUIManager } from "controllers/services/mensalidade/ui_manager"
import { MensalidadeCampoManager } from "controllers/services/mensalidade/campo_manager"
import { MensalidadeAPIManager } from "controllers/services/mensalidade/api_manager"


export class MensalidadeService {
  constructor(controller) {
    this.controller = controller
    this.modoEdicao = false
    this.pagamentoId = null
    this.uiManager = new MensalidadeUIManager(controller)
    this.campoManager = new MensalidadeCampoManager(controller)
    this.apiManager = new MensalidadeAPIManager(controller)
  }

  async atualizarValorMensalidade(event) {
    event.preventDefault()
    
    const valor = this.controller.valorMensalidadeTarget.value
    const diaVencimento = this.controller.diaVencimentoTarget.value
    
    if (!this.validarValorMensalidade(valor, diaVencimento)) {
      return
    }

    try {
      const data = await this.apiManager.atualizarValorMensalidade(valor, diaVencimento)
      
      if (data.success) {
        this.controller.mostrarMensagem(data.mensagem, 'success')
        setTimeout(() => location.reload(), 1500)
      } else {
        this.controller.mostrarMensagem(data.mensagem, 'error')
      }
    } catch (error) {
      this.controller.mostrarMensagem('Erro ao atualizar configuração', 'error')
    }
  }

  validarValorMensalidade(valor, diaVencimento) {
    if (!valor || parseFloat(valor) <= 0) {
      this.controller.mostrarMensagem('Por favor, insira um valor válido', 'error')
      return false
    }

    if (!diaVencimento || diaVencimento < 1 || diaVencimento > 31) {
      this.controller.mostrarMensagem('Dia de vencimento deve ser entre 1 e 31', 'error')
      return false
    }

    return true
  }

  async abrirModal(event) {
    const alunoId = event.currentTarget.dataset.alunoId
    const alunoNome = event.currentTarget.dataset.alunoNome
    
    this.controller.alunoAtual = alunoId
    this.controller.modalAlunoNomeTarget.textContent = alunoNome
    
    this.resetarEstado()
    
    try {
      const data = await this.apiManager.buscarInfoMensalidade(alunoId)
      
      this.pagamentoId = data.pagamento_id
      this.controller.valorTotalMensalidadeTarget.value = data.valor_total
      
      if (data.quitado) {
        this.configurarModoVisualizacao(data)
      } else {
        this.configurarModoRegistro(data)
      }
      
      this.uiManager.atualizarStatusVencimento(data)
      this.calcularPendente()
      
    } catch (error) {
      this.controller.mostrarMensagem('Erro ao carregar informações', 'error')
    }
    
    this.controller.modalMensalidadeTarget.classList.remove('hidden')
  }

  resetarEstado() {
    this.modoEdicao = false
    this.pagamentoId = null
  }

  configurarModoVisualizacao(data) {
    this.campoManager.configurarModoVisualizacao(data)
    this.uiManager.atualizarBotoesFooter(true)
  }

  configurarModoRegistro(data) {
    this.campoManager.configurarModoRegistro(data)
    this.uiManager.atualizarBotoesFooter(false)
  }

  habilitarEdicao() {
    this.modoEdicao = true
    this.campoManager.habilitarEdicao()
    this.uiManager.atualizarBotoesEdicao()
    this.controller.mostrarMensagem('Modo de edição ativado - você pode alterar o valor total pago', 'info')
  }

  calcularPendente() {
    this.uiManager.calcularPendente(this.modoEdicao)
  }

  async confirmarPagamento() {
    const caixaId = this.controller.caixaMensalidadeTarget.value
    const metodo = this.controller.metodoMensalidadeTarget.value
    const valorTotal = this.controller.valorTotalMensalidadeTarget.value

    if (!caixaId) {
      this.controller.mostrarMensagem("Por favor, selecione um caixa.", "error")
      return
    }

    const valorPago = this.obterValorPago()
    
    if (valorPago <= 0) {
      this.controller.mostrarMensagem(
        this.modoEdicao ? "Por favor, insira um valor pago válido." : "Por favor, insira o valor a pagar agora.",
        "error"
      )
      return
    }

    const dados = {
      alunoId: this.controller.alunoAtual,
      caixaId,
      metodo,
      valorTotal,
      valorPago
    }

    try {
      const data = await this.apiManager.registrarPagamento(dados, this.modoEdicao, this.pagamentoId)

      if (data.success) {
        const mensagem = data.message || data.mensagem || "Pagamento confirmado com sucesso!"
        this.controller.mostrarMensagem(mensagem, "success")
        
        if (this.controller.atualizarExtrato) {
           await this.controller.atualizarExtrato()
        }
        
        setTimeout(() => {
          this.fecharModal()
          window.location.reload()
        }, 1000)
      } else {
        const erro = data.message || data.mensagem || data.errors?.join(', ') || "Erro ao registrar mensalidade."
        this.controller.mostrarMensagem(erro, "error")
      }
    } catch (error) {
      this.controller.mostrarMensagem("Erro ao registrar mensalidade.", "error")
    }
  }

  obterValorPago() {
    if (this.modoEdicao) {
      return parseFloat(this.controller.valorPagoMensalidadeTarget.value) || 0
    } else {
      const campoValorPagarAgora = document.querySelector('[data-mensalidade-target="valorPagarAgora"]')
      return campoValorPagarAgora ? (parseFloat(campoValorPagarAgora.value) || 0) : 0
    }
  }

  fecharModal() {
    this.controller.modalMensalidadeTarget.classList.add('hidden')
    this.controller.alunoAtual = null
    this.resetarEstado()
  }
}