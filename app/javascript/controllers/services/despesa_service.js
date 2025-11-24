export class DespesaService {
  constructor(controller) {
    this.controller = controller
  }

  abrirModal() {
    if (!this.controller.hasModalDespesaTarget) {
      console.error("Target modalDespesa não encontrado")
      return
    }

    this.controller.modalDespesaTarget.classList.remove('hidden')

    if (this.controller.hasDescricaoDespesaTarget) {
      this.controller.descricaoDespesaTarget.value = ''
    }
    if (this.controller.hasValorDespesaTarget) {
      this.controller.valorDespesaTarget.value = ''
    }
    if (this.controller.hasCaixaDespesaTarget) {
      this.controller.caixaDespesaTarget.value = ''
    }
    if (this.controller.hasMetodoDespesaTarget) {
      this.controller.metodoDespesaTarget.value = 'Dinheiro'
    }
  }

  fecharModal() {
    if (this.controller.hasModalDespesaTarget) {
      this.controller.modalDespesaTarget.classList.add('hidden')
    }
  }

  async confirmarDespesa() {
    const descricao = this.controller.descricaoDespesaTarget.value.trim()
    const valor = this.controller.valorDespesaTarget.value
    const caixaId = this.controller.caixaDespesaTarget.value
    const metodo = this.controller.metodoDespesaTarget.value
    
    if (!descricao) {
      this.controller.mostrarMensagem("Por favor, insira uma descrição para a despesa.", "error")
      return
    }

    if (!valor || parseFloat(valor) <= 0) {
      this.controller.mostrarMensagem("Por favor, insira um valor válido.", "error")
      return
    }

    if (!caixaId) {
      this.controller.mostrarMensagem("Por favor, selecione um caixa.", "error")
      return
    }

    try {
      const response = await fetch('/financeiro/registrar_despesa', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.controller.getCSRFToken()
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
        this.controller.mostrarMensagem("Despesa registrada com sucesso!", "success")
        await this.controller.atualizarExtrato()
        setTimeout(() => {
          this.fecharModal()
          window.location.reload()
        }, 1000)
      } else {
        this.controller.mostrarMensagem(data.errors?.join(', ') || "Erro ao registrar despesa.", "error")
      }
    } catch (error) {
      console.error("Erro:", error)
      this.controller.mostrarMensagem("Erro ao registrar despesa.", "error")
    }
  }
}