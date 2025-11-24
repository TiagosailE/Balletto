
export class UIHelpers {
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