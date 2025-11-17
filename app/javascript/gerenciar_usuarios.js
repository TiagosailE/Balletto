function abrirModalUsuarios() {
  fetch('/configuracoes/listar_usuarios')
    .then(response => response.json())
    .then(users => {
      const container = document.getElementById('lista-usuarios');
      container.innerHTML = users.map(user => `
        <div class="flex items-center gap-3 p-3 bg-gray-50 dark:bg-[#0F0F0F] rounded-lg border border-gray-200 dark:border-[#2E2E2E] hover:border-[#C5A300] transition-colors">
          ${user.foto_url ? `
            <img src="${user.foto_url}" alt="${user.nome}" class="w-12 h-12 rounded-full object-cover border-2 border-[#C5A300] flex-shrink-0">
          ` : `
            <div class="w-12 h-12 bg-gradient-to-br from-[#C5A300] to-[#B88B00] rounded-full flex items-center justify-center text-white font-bold flex-shrink-0">
              ${user.iniciais}
            </div>
          `}
          <div class="flex-1 min-w-0">
            <p class="font-bold text-gray-900 dark:text-white truncate">${user.nome}</p>
            <p class="text-xs text-gray-500 dark:text-gray-400">@${user.usuario}</p>
          </div>
          <div class="flex items-center gap-2">
            ${user.role_badge}
            ${!user.is_current ? `
              <button onclick="excluirUsuario(${user.id}, '${user.nome}')" 
                      class="px-3 py-1.5 bg-red-500 text-white text-sm font-semibold rounded-lg hover:bg-red-600 transition-colors flex items-center gap-1.5 flex-shrink-0">
                <i class="fas fa-trash-alt text-xs"></i>
                Excluir
              </button>
            ` : '<span class="text-xs text-gray-400 italic px-3">Você</span>'}
          </div>
        </div>
      `).join('');
      
      document.getElementById('modal-usuarios').classList.remove('hidden');
    });
}

function fecharModalUsuarios() {
  document.getElementById('modal-usuarios').classList.add('hidden');
}

function excluirUsuario(id, nome) {
  const modal = document.getElementById('confirm-modal');
  const title = document.getElementById('confirm-title');
  const body = document.getElementById('confirm-body');
  const proceedBtn = document.getElementById('confirm-proceed');
  const cancelBtn = document.getElementById('confirm-cancel');
  
  title.textContent = 'Excluir Usuário';
  body.textContent = `Tem certeza que deseja excluir o usuário "${nome}"? Esta ação não pode ser desfeita.`;
  
  modal.classList.remove('hidden');
  
  const handleProceed = () => {
    fetch(`/configuracoes/excluir_usuario/${id}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        abrirModalUsuarios();
      } else {
        alert(data.error || 'Erro ao excluir usuário');
      }
      modal.classList.add('hidden');
    });
    
    proceedBtn.removeEventListener('click', handleProceed);
    cancelBtn.removeEventListener('click', handleCancel);
  };
  
  const handleCancel = () => {
    modal.classList.add('hidden');
    proceedBtn.removeEventListener('click', handleProceed);
    cancelBtn.removeEventListener('click', handleCancel);
  };
  
  proceedBtn.addEventListener('click', handleProceed);
  cancelBtn.addEventListener('click', handleCancel);
}

window.abrirModalUsuarios = abrirModalUsuarios;
window.fecharModalUsuarios = fecharModalUsuarios;
window.excluirUsuario = excluirUsuario;