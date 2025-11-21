function abrirModalUsuarios() {
  const modal = document.getElementById('modal-usuarios');
  const container = document.getElementById('lista-usuarios');

  if (container) {
    container.innerHTML = '<div class="text-center p-4 text-gray-500">Carregando usuários...</div>';
  }

  if (modal) {
    modal.classList.remove('hidden');
    document.body.style.overflow = 'hidden';
  }

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
        const avatarHtml = user.foto_url 
          ? `<img src="${user.foto_url}" alt="${user.usu_nome}" class="w-10 h-10 rounded-full object-cover border-2 border-[#C5A300] flex-shrink-0">`
          : `<div class="w-10 h-10 bg-gradient-to-br from-[#C5A300] to-[#B88B00] rounded-full flex items-center justify-center text-white font-bold text-xs flex-shrink-0 border-2 border-[#C5A300]">
               ${user.iniciais}
             </div>`;

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

              <button 
                onclick="confirmarExclusaoUsuario(${user.id}, '${user.usu_nome.replace(/'/g, "\\'")}')"
                class="p-2 text-gray-400 hover:text-red-500 transition-colors"
                title="Excluir">
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

function fecharModalUsuarios() {
  const modal = document.getElementById('modal-usuarios');
  if (modal) {
    modal.classList.add('hidden');
    document.body.style.overflow = 'auto';
  }
}

function confirmarExclusaoUsuario(id, nome) {
  openConfirmModal({
    title: "Confirmar Exclusão",
    body: `Tem certeza que deseja excluir o usuário "${nome}"?`,
    confirmText: "Excluir",
    confirmClass: "bg-red-600 hover:bg-red-500",
    confirmPath: `/users/${id}`
  });
}

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

window.abrirModalUsuarios = abrirModalUsuarios;
window.fecharModalUsuarios = fecharModalUsuarios;
window.confirmarExclusaoUsuario = confirmarExclusaoUsuario;
