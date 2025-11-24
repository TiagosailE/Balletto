export class ExtratoService {
  constructor(controller) {
    this.controller = controller
  }

  async atualizarExtrato() {
    try {
      const response = await fetch('/financeiro/extrato')
      const data = await response.json()
      
      this.renderizarExtrato(data.transacoes, data.totais)
    } catch (error) {
      console.error("Erro ao atualizar extrato:", error)
    }
  }

  renderizarExtrato(transacoes, totais) {
    this.atualizarTotais(totais)
    this.renderizarListaTransacoes(transacoes)
  }

  atualizarTotais(totais) {
    const totalReceitasEl = document.querySelector('[data-total-receitas]')
    const totalDespesasEl = document.querySelector('[data-total-despesas]')
    const saldoTotalEl = document.querySelector('[data-saldo-total]')
    
    if (totalReceitasEl) totalReceitasEl.textContent = this.controller.formatarMoeda(totais.total_receitas)
    if (totalDespesasEl) totalDespesasEl.textContent = this.controller.formatarMoeda(totais.total_despesas)
    if (saldoTotalEl) saldoTotalEl.textContent = this.controller.formatarMoeda(totais.saldo)
  }

  renderizarListaTransacoes(transacoes) {
    const tbody = document.querySelector('[data-lista-transacoes]')
    if (!tbody) return

    if (transacoes.length === 0) {
      tbody.innerHTML = `
        <tr>
          <td colspan="5" class="px-6 py-8 text-center text-gray-500 dark:text-gray-400">
            <i class="fas fa-file-invoice-dollar text-3xl mb-2"></i>
            <p>Nenhum lançamento financeiro encontrado.</p>
          </td>
        </tr>
      `
    } else {
      tbody.innerHTML = transacoes.map(t => this.renderizarLinhaTransacao(t)).join('')
    }
  }

  renderizarLinhaTransacao(t) {
    return `
      <tr class="hover:bg-gray-50 dark:hover:bg-[#252525] transition-colors">
        <td class="px-6 py-4 whitespace-nowrap">
          <div class="text-sm font-medium text-gray-900 dark:text-[#E5E5E5]">${t.descricao}</div>
          <div class="text-sm text-gray-500 dark:text-gray-400">${t.data}</div>
        </td>
        <td class="px-6 py-4 whitespace-nowrap">
          <span class="text-sm font-bold ${t.tipo === 'receita' ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'}">
            ${t.tipo === 'receita' ? '+' : '-'} ${this.controller.formatarMoeda(t.valor)}
          </span>
          <div class="text-sm text-gray-500 dark:text-gray-400">${t.caixa}</div>
        </td>
        <td class="px-6 py-4 whitespace-nowrap">
          <span class="px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${t.status === 'Pago' ? 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300' : 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-300'}">
            ${t.status}
          </span>
        </td>
        <td class="px-6 py-4 whitespace-nowrap">
          <span class="px-3 py-1 inline-flex items-center gap-1 text-xs leading-5 font-semibold rounded-full ${t.categoria_classe}">
            <i class="${t.categoria_icone}"></i> ${t.categoria}
          </span>
        </td>
        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
          ${t.associado || 'Lançamento Interno'}
        </td>
      </tr>
    `
  }
}