export class EventoService {
  constructor(controller) {
    this.controller = controller
  }

  async salvarValorEvento(event) {
    const button = event.currentTarget
    const eventoId = button.dataset.eventoId
    const input = this.controller.element.querySelector(`input[data-evento-id="${eventoId}"]`)
    const valor = input.value

    if (!valor || parseFloat(valor) < 0) {
      this.controller.mostrarMensagem("Por favor, insira um valor válido.", "error")
      return
    }

    try {
      button.disabled = true
      button.innerHTML = '<i class="fas fa-spinner fa-spin"></i>'

      const response = await fetch('/financeiro/atualizar_valor_evento', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.controller.getCSRFToken()
        },
        body: JSON.stringify({ evento_id: eventoId, valor: valor })
      })

      const data = await response.json()

      if (data.success) {
        this.controller.mostrarMensagem("Valor atualizado com sucesso!", "success")
      } else {
        this.controller.mostrarMensagem(data.errors?.join(', ') || "Erro ao atualizar valor.", "error")
      }
    } catch (error) {
      console.error("Erro:", error)
      this.controller.mostrarMensagem("Erro ao salvar valor do evento.", "error")
    } finally {
      button.disabled = false
      button.innerHTML = '<i class="fas fa-save"></i>'
    }
  }

  async abrirModalParticipantes(event) {
    const eventoId = event.currentTarget.dataset.eventoId
    this.controller.eventoAtual = eventoId
    
    this.controller.modalParticipantesTarget.classList.remove('hidden')
    this.controller.listaParticipantesTarget.innerHTML = `
      <div class="text-center py-8 text-gray-500 dark:text-gray-400">
        <i class="fas fa-spinner fa-spin text-3xl mb-2"></i>
        <p>Carregando participantes...</p>
      </div>
    `

    try {
      const response = await fetch(`/financeiro/participantes_evento/${eventoId}`)
      const data = await response.json()

      this.controller.modalEventoNomeTarget.textContent = data.evento.nome
      this.controller.modalEventoValorTarget.textContent = this.controller.formatarMoeda(data.evento.valor)

      this.renderizarParticipantes(data.participantes, data.caixas, data.evento.valor)
    } catch (error) {
      console.error("Erro:", error)
      this.controller.listaParticipantesTarget.innerHTML = `
        <div class="text-center py-8 text-red-500">
          <i class="fas fa-exclamation-triangle text-3xl mb-2"></i>
          <p>Erro ao carregar participantes.</p>
        </div>
      `
    }
  }

  renderizarParticipantes(participantes, caixas, valorEvento) {
    if (participantes.length === 0) {
      this.controller.listaParticipantesTarget.innerHTML = `
        <div class="text-center py-8 text-gray-500 dark:text-gray-400">
          <i class="fas fa-users-slash text-3xl mb-2"></i>
          <p>Nenhum participante confirmado ainda.</p>
        </div>
      `
      return
    }

    const caixasOptions = caixas.map(c => 
      `<option value="${c.id}">${c.nome}</option>`
    ).join('')

    const html = `
      <div class="space-y-3">
        ${participantes.map(p => this.renderizarParticipante(p, caixasOptions, valorEvento)).join('')}
      </div>
    `

    this.controller.listaParticipantesTarget.innerHTML = html
  }

  renderizarParticipante(p, caixasOptions, valorEvento) {
    const statusClass = p.pago 
      ? 'bg-green-50 dark:bg-green-900/20 border-green-200 dark:border-green-800' 
      : p.valor_pago > 0
      ? 'bg-yellow-50 dark:bg-yellow-900/20 border-yellow-200 dark:border-yellow-800'
      : 'bg-gray-50 dark:bg-[#111111] border-gray-200 dark:border-[#2E2E2E]'

    const foto = p.foto_url 
      ? `<img src="${p.foto_url}" class="w-10 h-10 rounded-full object-cover" alt="${p.nome}">`
      : `<div class="w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 to-purple-600 flex items-center justify-center text-white font-bold">
           ${this.controller.getIniciais(p.nome)}
         </div>`

    const statusInfo = p.pago 
      ? '<span class="text-green-600 dark:text-green-400 font-semibold">✓ Quitado</span>'
      : p.valor_pago > 0
      ? `Pago: ${this.controller.formatarMoeda(p.valor_pago)} | Falta: ${this.controller.formatarMoeda(p.valor_pendente)}`
      : `Total: ${this.controller.formatarMoeda(valorEvento)}`

    const formPagamento = !p.pago 
      ? `<div class="space-y-2">
           <input 
             type="number" 
             step="0.01"
             placeholder="Valor pago"
             data-aluno-id="${p.id}"
             data-valor-pago-input
             class="w-full px-3 py-2 text-sm border border-gray-300 dark:border-[#2E2E2E] rounded-lg bg-white dark:bg-[#0A0A0A] text-gray-900 dark:text-[#E5E5E5]">
           <div class="flex gap-2">
             <select 
               data-aluno-id="${p.id}"
               data-caixa-select
               class="flex-1 px-3 py-2 text-sm border border-gray-300 dark:border-[#2E2E2E] rounded-lg bg-white dark:bg-[#0A0A0A] text-gray-900 dark:text-[#E5E5E5]">
               <option value="">Caixa</option>
               ${caixasOptions}
             </select>
             <select 
               data-aluno-id="${p.id}"
               data-metodo-select
               class="flex-1 px-3 py-2 text-sm border border-gray-300 dark:border-[#2E2E2E] rounded-lg bg-white dark:bg-[#0A0A0A] text-gray-900 dark:text-[#E5E5E5]">
               <option value="Dinheiro">Dinheiro</option>
               <option value="Cartão de Crédito">Cartão</option>
               <option value="PIX">PIX</option>
               <option value="Transferência">Transferência</option>
             </select>
             <button 
               data-action="click->financeiro#registrarPagamentoEvento"
               data-aluno-id="${p.id}"
               class="px-4 py-2 text-sm bg-purple-600 text-white font-semibold rounded-lg hover:bg-purple-700 transition-colors whitespace-nowrap">
               Registrar
             </button>
           </div>
         </div>`
      : '<div class="flex items-center gap-2 text-green-600 dark:text-green-400"><i class="fas fa-check-circle"></i><span class="font-semibold">Pagamento completo</span></div>'

    return `
      <div class="p-4 rounded-lg border ${statusClass}">
        <div class="flex items-center justify-between mb-3">
          <div class="flex items-center gap-3 flex-1">
            ${foto}
            <div>
              <div class="font-medium text-gray-900 dark:text-[#E5E5E5]">${p.nome}</div>
              <div class="text-sm text-gray-500 dark:text-gray-400">${statusInfo}</div>
            </div>
          </div>
        </div>
        ${formPagamento}
      </div>
    `
  }

  async registrarPagamentoEvento(event) {
    const button = event.currentTarget
    const alunoId = button.dataset.alunoId
    const valorPagoInput = this.controller.listaParticipantesTarget.querySelector(`input[data-valor-pago-input][data-aluno-id="${alunoId}"]`)
    const caixaSelect = this.controller.listaParticipantesTarget.querySelector(`select[data-caixa-select][data-aluno-id="${alunoId}"]`)
    const metodoSelect = this.controller.listaParticipantesTarget.querySelector(`select[data-metodo-select][data-aluno-id="${alunoId}"]`)
    
    const valorPago = valorPagoInput.value
    const caixaId = caixaSelect.value
    const metodo = metodoSelect.value

    if (!valorPago || parseFloat(valorPago) <= 0) {
      this.controller.mostrarMensagem("Por favor, insira o valor pago.", "error")
      return
    }

    if (!caixaId) {
      this.controller.mostrarMensagem("Por favor, selecione um caixa.", "error")
      return
    }

    try {
      button.disabled = true
      button.innerHTML = '<i class="fas fa-spinner fa-spin"></i>'

      const response = await fetch('/financeiro/registrar_pagamento_evento', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.controller.getCSRFToken()
        },
        body: JSON.stringify({
          evento_id: this.controller.eventoAtual,
          aluno_id: alunoId,
          caixa_id: caixaId,
          metodo: metodo,
          valor_pago: valorPago
        })
      })

      const data = await response.json()

      if (data.success) {
        this.controller.mostrarMensagem(data.message, "success")
        await this.controller.atualizarExtrato()
        setTimeout(() => {
          this.abrirModalParticipantes({ currentTarget: { dataset: { eventoId: this.controller.eventoAtual } } })
        }, 500)
        window.location.reload()
      } else {
        this.controller.mostrarMensagem(data.errors?.join(', ') || "Erro ao registrar pagamento.", "error")
        button.disabled = false
        button.innerHTML = 'Registrar'
      }
    } catch (error) {
      console.error("Erro:", error)
      this.controller.mostrarMensagem("Erro ao registrar pagamento.", "error")
      button.disabled = false
      button.innerHTML = 'Registrar'
    }
  }

  fecharModal() {
    this.controller.modalParticipantesTarget.classList.add('hidden')
    this.controller.eventoAtual = null
  }
}