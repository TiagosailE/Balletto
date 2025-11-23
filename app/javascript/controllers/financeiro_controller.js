import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
  "valorEvento",
  "valorMensalidade",
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
    if (this.hasValorTotalMensalidadeTarget && this.hasValorPagoMensalidadeTarget) {
      this.valorTotalMensalidadeTarget.addEventListener('input', () => this.calcularPendenteMensalidade())
      this.valorPagoMensalidadeTarget.addEventListener('input', () => this.calcularPendenteMensalidade())
    }
  }
  
  async salvarValorEvento(event) {
    const button = event.currentTarget
    const eventoId = button.dataset.eventoId
    const input = this.element.querySelector(`input[data-evento-id="${eventoId}"]`)
    const valor = input.value

    if (!valor || parseFloat(valor) < 0) {
      this.mostrarMensagem("Por favor, insira um valor válido.", "error")
      return
    }

    try {
      button.disabled = true
      button.innerHTML = '<i class="fas fa-spinner fa-spin"></i>'

      const response = await fetch('/financeiro/atualizar_valor_evento', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        },
        body: JSON.stringify({ evento_id: eventoId, valor: valor })
      })

      const data = await response.json()

      if (data.success) {
        this.mostrarMensagem("Valor atualizado com sucesso!", "success")
      } else {
        this.mostrarMensagem(data.errors?.join(', ') || "Erro ao atualizar valor.", "error")
      }
    } catch (error) {
      console.error("Erro:", error)
      this.mostrarMensagem("Erro ao salvar valor do evento.", "error")
    } finally {
      button.disabled = false
      button.innerHTML = '<i class="fas fa-save"></i>'
    }
  }

  async abrirModalParticipantes(event) {
    const eventoId = event.currentTarget.dataset.eventoId
    this.eventoAtual = eventoId
    
    this.modalParticipantesTarget.classList.remove('hidden')
    this.listaParticipantesTarget.innerHTML = `
      <div class="text-center py-8 text-gray-500 dark:text-gray-400">
        <i class="fas fa-spinner fa-spin text-3xl mb-2"></i>
        <p>Carregando participantes...</p>
      </div>
    `

    try {
      const response = await fetch(`/financeiro/participantes_evento/${eventoId}`)
      const data = await response.json()

      this.modalEventoNomeTarget.textContent = data.evento.nome
      this.modalEventoValorTarget.textContent = this.formatarMoeda(data.evento.valor)

      this.renderizarParticipantes(data.participantes, data.caixas, data.evento.valor)
    } catch (error) {
      console.error("Erro:", error)
      this.listaParticipantesTarget.innerHTML = `
        <div class="text-center py-8 text-red-500">
          <i class="fas fa-exclamation-triangle text-3xl mb-2"></i>
          <p>Erro ao carregar participantes.</p>
        </div>
      `
    }
  }

  renderizarParticipantes(participantes, caixas, valorEvento) {
    if (participantes.length === 0) {
      this.listaParticipantesTarget.innerHTML = `
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
        ${participantes.map(p => `
          <div class="p-4 rounded-lg border ${
            p.pago 
              ? 'bg-green-50 dark:bg-green-900/20 border-green-200 dark:border-green-800' 
              : p.valor_pago > 0
              ? 'bg-yellow-50 dark:bg-yellow-900/20 border-yellow-200 dark:border-yellow-800'
              : 'bg-gray-50 dark:bg-[#111111] border-gray-200 dark:border-[#2E2E2E]'
          }">
            <div class="flex items-center justify-between mb-3">
              <div class="flex items-center gap-3 flex-1">
                ${p.foto_url 
                  ? `<img src="${p.foto_url}" class="w-10 h-10 rounded-full object-cover" alt="${p.nome}">`
                  : `<div class="w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 to-purple-600 flex items-center justify-center text-white font-bold">
                       ${this.getIniciais(p.nome)}
                     </div>`
                }
                <div>
                  <div class="font-medium text-gray-900 dark:text-[#E5E5E5]">${p.nome}</div>
                  <div class="text-sm text-gray-500 dark:text-gray-400">
                    ${p.pago 
                      ? '<span class="text-green-600 dark:text-green-400 font-semibold">✓ Quitado</span>'
                      : p.valor_pago > 0
                      ? `Pago: ${this.formatarMoeda(p.valor_pago)} | Falta: ${this.formatarMoeda(p.valor_pendente)}`
                      : `Total: ${this.formatarMoeda(valorEvento)}`
                    }
                  </div>
                </div>
              </div>
            </div>
            
            ${!p.pago 
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
            }
          </div>
        `).join('')}
      </div>
    `

    this.listaParticipantesTarget.innerHTML = html
  }

  async registrarPagamentoEvento(event) {
    const button = event.currentTarget
    const alunoId = button.dataset.alunoId
    const valorPagoInput = this.listaParticipantesTarget.querySelector(`input[data-valor-pago-input][data-aluno-id="${alunoId}"]`)
    const caixaSelect = this.listaParticipantesTarget.querySelector(`select[data-caixa-select][data-aluno-id="${alunoId}"]`)
    const metodoSelect = this.listaParticipantesTarget.querySelector(`select[data-metodo-select][data-aluno-id="${alunoId}"]`)
    
    const valorPago = valorPagoInput.value
    const caixaId = caixaSelect.value
    const metodo = metodoSelect.value

    if (!valorPago || parseFloat(valorPago) <= 0) {
      this.mostrarMensagem("Por favor, insira o valor pago.", "error")
      return
    }

    if (!caixaId) {
      this.mostrarMensagem("Por favor, selecione um caixa.", "error")
      return
    }

    try {
      button.disabled = true
      button.innerHTML = '<i class="fas fa-spinner fa-spin"></i>'

      const response = await fetch('/financeiro/registrar_pagamento_evento', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        },
        body: JSON.stringify({
          evento_id: this.eventoAtual,
          aluno_id: alunoId,
          caixa_id: caixaId,
          metodo: metodo,
          valor_pago: valorPago
        })
      })

      const data = await response.json()

      if (data.success) {
        this.mostrarMensagem(data.message, "success")
        setTimeout(() => {
          this.abrirModalParticipantes({ currentTarget: { dataset: { eventoId: this.eventoAtual } } })
        }, 1000)
      } else {
        this.mostrarMensagem(data.errors?.join(', ') || "Erro ao registrar pagamento.", "error")
        button.disabled = false
        button.innerHTML = 'Registrar'
      }
    } catch (error) {
      console.error("Erro:", error)
      this.mostrarMensagem("Erro ao registrar pagamento.", "error")
      button.disabled = false
      button.innerHTML = 'Registrar'
    }
  }

  fecharModalParticipantes() {
    this.modalParticipantesTarget.classList.add('hidden')
    this.eventoAtual = null
  }

  async atualizarValorMensalidade(event) {
  const button = event.currentTarget
  const valor = this.valorMensalidadeTarget.value

  if (!valor || parseFloat(valor) < 0) {
    this.mostrarMensagem("Por favor, insira um valor válido.", "error")
    return
  }

  try {
    button.disabled = true
    button.innerHTML = '<i class="fas fa-spinner fa-spin"></i>'

    const response = await fetch('/financeiro/atualizar_valor_mensalidade', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': this.getCSRFToken()
      },
      body: JSON.stringify({ valor: valor })
    })

    const data = await response.json()

    if (data.success) {
      this.mostrarMensagem("Valor da mensalidade atualizado!", "success")

      if (this.hasValorTotalMensalidadeTarget) {
        this.valorTotalMensalidadeTarget.value = valor
        this.calcularPendenteMensalidade()
      }
    } else {
      this.mostrarMensagem("Erro ao atualizar valor.", "error")
    }
  } catch (error) {
    console.error("Erro:", error)
    this.mostrarMensagem("Erro ao atualizar valor da mensalidade.", "error")
  } finally {
    button.disabled = false
    button.innerHTML = 'Atualizar'
  }
}

  abrirModalMensalidade(event) {
    const alunoId = event.currentTarget.dataset.alunoId
    const alunoNome = event.currentTarget.dataset.alunoNome
    
    this.alunoAtual = alunoId
    this.modalAlunoNomeTarget.textContent = alunoNome
    this.valorPagoMensalidadeTarget.value = ''
    this.calcularPendenteMensalidade()
    this.modalMensalidadeTarget.classList.remove('hidden')
  }

  calcularPendenteMensalidade() {
  const total = parseFloat(this.valorTotalMensalidadeTarget.value) || 0
  const pago = parseFloat(this.valorPagoMensalidadeTarget.value) || 0
  const diferenca = total - pago
  
  const container = this.element.querySelector('[data-financeiro-target="statusPagamentoContainer"]')
  const label = this.element.querySelector('[data-financeiro-target="statusPagamentoLabel"]')
  const valor = this.valorPendenteMensalidadeTarget
  
  if (diferenca < 0) {
    const troco = Math.abs(diferenca)
    label.textContent = 'Troco:'
    valor.textContent = this.formatarMoeda(troco)
    valor.className = 'text-lg font-bold text-blue-600 dark:text-blue-400'
    container.className = 'p-3 rounded-lg bg-blue-50 dark:bg-blue-900/20'
  } else if (diferenca === 0) {
    label.textContent = 'Status:'
    valor.textContent = 'Quitado'
    valor.className = 'text-lg font-bold text-green-600 dark:text-green-400'
    container.className = 'p-3 rounded-lg bg-green-50 dark:bg-green-900/20'
  } else if (pago > 0) {
    label.textContent = 'Valor Pendente:'
    valor.textContent = this.formatarMoeda(diferenca)
    valor.className = 'text-lg font-bold text-yellow-600 dark:text-yellow-400'
    container.className = 'p-3 rounded-lg bg-yellow-50 dark:bg-yellow-900/20'
  } else {
    label.textContent = 'Valor Pendente:'
    valor.textContent = this.formatarMoeda(diferenca)
    valor.className = 'text-lg font-bold text-red-600 dark:text-red-400'
    container.className = 'p-3 rounded-lg bg-red-50 dark:bg-red-900/20'
  }
}

  async confirmarPagamentoMensalidade() {
    const caixaId = this.caixaMensalidadeTarget.value
    const metodo = this.metodoMensalidadeTarget.value
    const valorTotal = this.valorTotalMensalidadeTarget.value
    const valorPago = this.valorPagoMensalidadeTarget.value

    if (!caixaId) {
      this.mostrarMensagem("Por favor, selecione um caixa.", "error")
      return
    }

    if (!valorPago || parseFloat(valorPago) <= 0) {
      this.mostrarMensagem("Por favor, insira o valor pago.", "error")
      return
    }

    try {
      const response = await fetch('/financeiro/registrar_pagamento_mensalidade', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        },
        body: JSON.stringify({
          aluno_id: this.alunoAtual,
          caixa_id: caixaId,
          metodo: metodo,
          valor_total: valorTotal,
          valor_pago: valorPago
        })
      })

      const data = await response.json()

      if (data.success) {
        this.mostrarMensagem(data.message, "success")
        setTimeout(() => {
          this.fecharModalMensalidade()
          window.location.reload()
        }, 1000)
      } else {
        this.mostrarMensagem(data.errors?.join(', ') || "Erro ao registrar mensalidade.", "error")
      }
    } catch (error) {
      console.error("Erro:", error)
      this.mostrarMensagem("Erro ao registrar mensalidade.", "error")
    }
  }

  fecharModalMensalidade() {
    this.modalMensalidadeTarget.classList.add('hidden')
    this.alunoAtual = null
  }

abrirModalDespesa() {
  this.modalDespesaTarget.classList.remove('hidden')
  this.descricaoDespesaTarget.value = ''
  this.valorDespesaTarget.value = ''
  this.caixaDespesaTarget.value = ''
  this.metodoDespesaTarget.value = 'Dinheiro'
}

fecharModalDespesa() {
  this.modalDespesaTarget.classList.add('hidden')
}

async confirmarDespesa() {
  const descricao = this.descricaoDespesaTarget.value.trim()
  const valor = this.valorDespesaTarget.value
  const caixaId = this.caixaDespesaTarget.value
  const metodo = this.metodoDespesaTarget.value
  if (!descricao) {
    this.mostrarMensagem("Por favor, insira uma descrição para a despesa.", "error")
    return
  }

  if (!valor || parseFloat(valor) <= 0) {
    this.mostrarMensagem("Por favor, insira um valor válido.", "error")
    return
  }

  if (!caixaId) {
    this.mostrarMensagem("Por favor, selecione um caixa.", "error")
    return
  }

  try {
    const response = await fetch('/financeiro/registrar_despesa', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': this.getCSRFToken()
      },
      body: JSON.stringify({
        descricao: descricao,
        valor: valor,
        caixa_id: caixaId,
        metodo: metodo
      })
    })

    const data = await response.json()

    if (data.success) {
      this.mostrarMensagem("Despesa registrada com sucesso!", "success")
      setTimeout(() => {
        this.fecharModalDespesa()
        
      }, 1000)
    } else {
      this.mostrarMensagem(data.errors?.join(', ') || "Erro ao registrar despesa.", "error")
    }
  } catch (error) {
    console.error("Erro:", error)
    this.mostrarMensagem("Erro ao registrar despesa.", "error")
  }
}

  getCSRFToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || ''
  }

  formatarMoeda(valor) {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL'
    }).format(valor || 0)
  }

  getIniciais(nome) {
    return nome.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2)
  }

  mostrarMensagem(texto, tipo = "info") {
    const toast = document.createElement('div')
    const cores = {
      success: 'bg-green-500',
      error: 'bg-red-500',
      info: 'bg-blue-500'
    }
    
    toast.className = `fixed top-4 right-4 ${cores[tipo]} text-white px-6 py-3 rounded-lg shadow-lg z-[9999] transition-opacity duration-300`
    toast.innerHTML = `
      <div class="flex items-center gap-2">
        <i class="fas fa-${tipo === 'success' ? 'check-circle' : tipo === 'error' ? 'exclamation-circle' : 'info-circle'}"></i>
        <span>${texto}</span>
      </div>
    `
    
    document.body.appendChild(toast)
    
    setTimeout(() => {
      toast.style.opacity = '0'
      setTimeout(() => toast.remove(), 300)
    }, 3000)
  }
}