// Função para abrir a modal e carregar a lista
function abrirModalUsuarios() {
  const modal = document.getElementById('modal-usuarios');
  const container = document.getElementById('lista-usuarios');

  // Mostra loading enquanto carrega
  if (container) {
    container.innerHTML = '<div class="text-center p-4 text-gray-500">Carregando usuários...</div>';
  }

  // Abre a modal visualmente
  if (modal) {
    modal.classList.remove('hidden');
    document.body.style.overflow = 'hidden';
  }

  // Busca os dados na rota padrão do Rails (formato JSON)
  fetch('/users.json')
    .then(response => {
      if (!response.ok) throw new Error('Erro ao carregar usuários');
      return response.json();
    })
    .then(users => {
      if (!container) return;

      if (users.length === 0) {
        container.innerHTML = '<div class="text-center p-4 text-gray-500">Nenhum usuário encontrado.</div>';
        return;
      }

      container.innerHTML = users.map(user => {
        // Lógica para avatar (Foto ou Iniciais)
        const avatarHtml = user.foto_url 
          ? `<img src="${user.foto_url}" alt="${user.usu_nome}" class="w-10 h-10 rounded-full object-cover border-2 border-[#C5A300] flex-shrink-0">`
          : `<div class="w-10 h-10 bg-gradient-to-br from-[#C5A300] to-[#B88B00] rounded-full flex items-center justify-center text-white font-bold text-xs flex-shrink-0 border-2 border-[#C5A300]">
               ${user.iniciais}
             </div>`;

        // Renderiza a linha do usuário
        return `
          <div class="flex items-center justify-between p-3 bg-gray-50 dark:bg-[#0A0A0A] rounded-lg border border-gray-200 dark:border-[#2E2E2E] hover:border-[#C5A300] transition-colors group">
            <div class="flex items-center gap-3 min-w-0">
              ${avatarHtml}
              <div class="min-w-0">
                <p class="text-sm font-bold text-gray-900 dark:text-white truncate">${user.usu_nome}</p>
                <p class="text-xs text-gray-500 dark:text-gray-400 truncate">@${user.usu_login}</p>
              </div>
            </div>
            
            <div class="flex items-center gap-2 opacity-100 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity">
              <a href="/users/${user.id}/edit" class="p-2 text-gray-400 hover:text-[#C5A300] transition-colors" title="Editar">
                <i class="fas fa-edit"></i>
              </a>
              <button onclick="confirmarExclusaoUsuario(${user.id}, '${user.usu_nome}')" class="p-2 text-gray-400 hover:text-red-500 transition-colors" title="Excluir">
                <i class="fas fa-trash"></i>
              </button>
            </div>
          </div>
        `;
      }).join('');
    })
    .catch(error => {
      console.error('Erro:', error);
      if (container) container.innerHTML = '<div class="text-center p-4 text-red-500">Erro ao carregar lista.</div>';
    });
}

// Função para fechar a modal
function fecharModalUsuarios() {
  const modal = document.getElementById('modal-usuarios');
  if (modal) {
    modal.classList.add('hidden');
    document.body.style.overflow = 'auto';
  }
}

// Lógica de Exclusão via AJAX
function confirmarExclusaoUsuario(id, nome) {
  if (!confirm(`Tem certeza que deseja excluir o usuário "${nome}"?`)) return;

  const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

  fetch(`/users/${id}.json`, {
    method: 'DELETE',
    headers: {
      'X-CSRF-Token': csrfToken,
      'Content-Type': 'application/json'
    }
  })
  .then(response => {
    if (response.ok) {
      // Recarrega a lista sem fechar a modal
      abrirModalUsuarios();
    } else {
      alert('Erro ao excluir usuário.');
    }
  })
  .catch(error => {
    console.error('Erro:', error);
    alert('Erro de conexão.');
  });
}

// Listeners globais para fechar a modal (ESC e Clique fora)
document.addEventListener('DOMContentLoaded', () => {
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') fecharModalUsuarios();
  });

  const modal = document.getElementById('modal-usuarios');
  if (modal) {
    modal.addEventListener('click', (e) => {
      if (e.target === modal) fecharModalUsuarios();
    });
  }
});

// Disponibiliza as funções globalmente para o onclick funcionar no HTML
window.abrirModalUsuarios = abrirModalUsuarios;
window.fecharModalUsuarios = fecharModalUsuarios;
window.confirmarExclusaoUsuario = confirmarExclusaoUsuario;