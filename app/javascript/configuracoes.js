document.addEventListener('DOMContentLoaded', function() {
  const fileInput = document.getElementById('user_foto');
  const filenameDisplay = document.getElementById('filename-display');
  const previewFoto = document.getElementById('preview-foto');

  if (fileInput) {
    fileInput.addEventListener('change', function(e) {
      const file = e.target.files[0];
      if (file) {
        filenameDisplay.textContent = file.name;
        filenameDisplay.classList.remove('italic');
        filenameDisplay.classList.add('font-medium', 'text-[#C5A300]');

        const reader = new FileReader();
        reader.onload = function(event) {
          if (previewFoto.tagName === 'IMG') {
            previewFoto.src = event.target.result;
          } else {
            const newImg = document.createElement('img');
            newImg.src = event.target.result;
            newImg.className = 'w-32 h-32 rounded-full object-cover border-4 border-[#C5A300] shadow-lg';
            newImg.id = 'preview-foto';
            previewFoto.parentNode.replaceChild(newImg, previewFoto);
          }
        };
        reader.readAsDataURL(file);
      }
    });
  }
});

function abrirModalUsuarios() {
  const modal = document.getElementById('modal-usuarios');
  modal.classList.remove('hidden');
  carregarUsuarios();
}

function fecharModalUsuarios() {
  const modal = document.getElementById('modal-usuarios');
  modal.classList.add('hidden');
}

function carregarUsuarios() {
  fetch('/configuracoes/listar_usuarios')
    .then(response => response.json())
    .then(users => {
      const lista = document.getElementById('lista-usuarios');
      lista.innerHTML = users.map(user => `
        <div class="bg-gray-50 dark:bg-[#0F0F0F] rounded-xl p-4 border border-gray-200 dark:border-[#2E2E2E] flex items-center justify-between hover:shadow-md transition-all">
          <div class="flex items-center gap-3">
            ${user.foto_url 
              ? `<img src="${user.foto_url}" class="w-14 h-14 rounded-full object-cover border-2 border-[#C5A300]" alt="${user.nome}">` 
              : `<div class="w-14 h-14 bg-gradient-to-br from-[#C5A300] to-[#B88B00] rounded-full flex items-center justify-center text-white text-lg font-bold border-2 border-[#C5A300]">${user.iniciais}</div>`
            }
            <div>
              <h4 class="font-bold text-gray-900 dark:text-white">${user.nome}</h4>
              <p class="text-sm text-gray-500 dark:text-gray-400">@${user.usuario}</p>
            </div>
          </div>
          <div class="flex items-center gap-2">
            ${user.role_badge}
            ${user.is_current 
              ? '<span class="text-xs text-gray-400 dark:text-gray-500 italic">(Você)</span>' 
              : `<button onclick="confirmarExclusao(${user.id}, '${user.nome}')" class="px-3 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg transition-all">
                   <i class="fas fa-trash"></i>
                 </button>`
            }
          </div>
        </div>
      `).join('');
    })
    .catch(error => {
      console.error('Erro ao carregar usuários:', error);
      const lista = document.getElementById('lista-usuarios');
      lista.innerHTML = '<p class="text-red-500 text-center">Erro ao carregar usuários</p>';
    });
}

function confirmarExclusao(userId, userName) {
  const modal = document.getElementById('confirm-modal');
  const titleEl = document.getElementById('confirm-title');
  const bodyEl = document.getElementById('confirm-body');
  const cancelBtn = document.getElementById('confirm-cancel');
  const proceedBtn = document.getElementById('confirm-proceed');

  titleEl.textContent = 'Confirmar Exclusão';
  bodyEl.textContent = `Tem certeza que deseja excluir o usuário "${userName}"?`;

  modal.classList.remove('hidden');

  const newCancelBtn = cancelBtn.cloneNode(true);
  cancelBtn.parentNode.replaceChild(newCancelBtn, cancelBtn);
  newCancelBtn.addEventListener('click', () => {
    modal.classList.add('hidden');
  });

  const newProceedBtn = proceedBtn.cloneNode(true);
  proceedBtn.parentNode.replaceChild(newProceedBtn, proceedBtn);
  newProceedBtn.addEventListener('click', () => {
    excluirUsuario(userId);
    modal.classList.add('hidden');
  });
}

function excluirUsuario(userId) {
  fetch(`/configuracoes/excluir_usuario/${userId}`, {  
    method: 'DELETE',
    headers: {
      'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
      'Content-Type': 'application/json'
    }
  })
  .then(response => response.json())
  .then(data => {
    if (data.success) {
      carregarUsuarios();
    } else {
      alert(data.error || 'Erro ao excluir usuário');
    }
  })
  .catch(error => {
    console.error('Erro:', error);
    alert('Erro ao excluir usuário');
  });
}
