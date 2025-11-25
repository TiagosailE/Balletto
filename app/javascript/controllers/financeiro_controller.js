import { Controller } from "@hotwired/stimulus"
import { EventoService } from "controllers/services/evento_service"
import { MensalidadeService } from "controllers/services/mensalidade_service"
import { DespesaService } from "controllers/services/despesa_service"
import { ExtratoService } from "controllers/services/extrato_service"
import { UIHelpers } from "controllers/helpers/ui_helpers"
import { FormHelpers } from "controllers/helpers/form_helpers"

export default class extends Controller {
  static targets = [
  "valorMensalidade",
  "diaVencimento",
  "modalParticipantes",
  "modalMensalidade",
  "modalDespesa",
  "listaParticipantes",
  "modalEventoNome",
  "modalEventoValor",
  "modalAlunoNome",
  "valorTotalMensalidade",
  "valorPagoMensalidade",
  "valorPendenteMensalidade",
  "valorPendenteContainer",
  "caixaMensalidade",
  "metodoMensalidade",
  "statusPagamentoContainer",
  "statusPagamentoLabel",
  "descricaoDespesa",
  "valorDespesa",
  "caixaDespesa",
  "metodoDespesa"
]

  connect() {
    console.log("Financeiro controller conectado!")
    this.eventoAtual = null
    this.alunoAtual = null

    this.uiHelpers = new UIHelpers()
    this.formHelpers = new FormHelpers()

    this.eventoService = new EventoService(this)
    this.mensalidadeService = new MensalidadeService(this)
    this.despesaService = new DespesaService(this)
    this.extratoService = new ExtratoService(this)

    this.carregarCaixas()
    this.setupEventListeners()
  }

  setupEventListeners() {
    if (this.hasValorTotalMensalidadeTarget && this.hasValorPagoMensalidadeTarget) {
      this.valorTotalMensalidadeTarget.addEventListener('input', () => this.calcularPendenteMensalidade())
      this.valorPagoMensalidadeTarget.addEventListener('input', () => this.calcularPendenteMensalidade())
    }
  }

  async carregarCaixas() {
    try {
      const caixasElements = document.querySelectorAll('select[data-financeiro-target="caixaMensalidade"]')
      if (caixasElements.length > 0) {
        const options = Array.from(caixasElements[0].options)
          .filter(opt => opt.value)
          .map(opt => ({ id: opt.value, nome: opt.text }))
        window.caixasData = options
      }
    } catch (error) {
      console.error("Erro ao carregar caixas:", error)
    }
  }

  async salvarValorEvento(event) {
    await this.eventoService.salvarValorEvento(event)
  }

  async abrirModalParticipantes(event) {
    await this.eventoService.abrirModalParticipantes(event)
  }

  async registrarPagamentoEvento(event) {
    await this.eventoService.registrarPagamentoEvento(event)
  }

  fecharModalParticipantes() {
    this.eventoService.fecharModal()
  }

  async atualizarValorMensalidade(event) {
    await this.mensalidadeService.atualizarValorMensalidade(event)
  }

  async abrirModalMensalidade(event) {
    await this.mensalidadeService.abrirModal(event)
  }

  calcularPendenteMensalidade() {
    this.mensalidadeService.calcularPendente()
  }

  async confirmarPagamentoMensalidade() {
    await this.mensalidadeService.confirmarPagamento()
  }

  fecharModalMensalidade() {
    this.mensalidadeService.fecharModal()
  }

  abrirModalDespesa() {
    this.despesaService.abrirModal()
  }

  fecharModalDespesa() {
    this.despesaService.fecharModal()
  }

  async confirmarDespesa() {
    await this.despesaService.confirmarDespesa()
  }

  async atualizarExtrato() {
    await this.extratoService.atualizarExtrato()
  }

  getCSRFToken() {
    return this.formHelpers.getCSRFToken()
  }

  formatarMoeda(valor) {
    return this.uiHelpers.formatarMoeda(valor)
  }

  getIniciais(nome) {
    return this.uiHelpers.getIniciais(nome)
  }

  mostrarMensagem(texto, tipo = "info") {
    this.uiHelpers.mostrarMensagem(texto, tipo)
  }
}