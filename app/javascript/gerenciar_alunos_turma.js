document.addEventListener('turbo:load', () => {
  window.abrirModalAlunos = function(element) {
    const turmaId = element.dataset.turmaId;
    const turmaNome = element.dataset.turmaNome;
    
    console.log("Abrindo modal para turma:", turmaId, turmaNome);

    const modalTituloElement = document.getElementById('modal-turma-nome');
    if (modalTituloElement) {
      modalTituloElement.textContent = turmaNome;
    }

    fetch(`/turmas/${turmaId}/listar_alunos`)
      .then(response => response.json())
      .then(alunos => {
        const container = document.getElementById('modal-alunos-container');
        
        if (alunos.length === 0) {
          container.innerHTML = `
            <div class="col-span-full text-center p-8">
              <i class="fas fa-user-slash text-4xl mb-4 text-gray-400 dark:text-gray-600"></i>
              <h3 class="text-lg font-semibold text-gray-700 dark:text-gray-300">Nenhum aluno matriculado</h3>
              <p class="mt-1 text-gray-500 dark:text-gray-400">Esta turma ainda não possui alunos.</p>
            </div>
          `;
        } else {
          container.innerHTML = alunos.map(aluno => `
            <div class="flex flex-col items-center p-4 bg-gray-50 dark:bg-[#0F0F0F] rounded-lg border border-gray-200 dark:border-[#2E2E2E] hover:border-[#C5A300] transition-colors group">
              ${aluno.foto_url ? `
                <img src="${aluno.foto_url}" alt="${aluno.nome}" class="w-20 h-20 rounded-full object-cover border-2 border-[#C5A300] mb-3">
              ` : `
                <div class="w-20 h-20 bg-gradient-to-br from-[#C5A300] to-[#B88B00] rounded-full flex items-center justify-center text-white font-bold text-2xl mb-3 border-2 border-[#C5A300]">
                  ${aluno.iniciais}
                </div>
              `}
              <p class="font-bold text-gray-900 dark:text-white text-center text-sm mb-1">${aluno.nome}</p>
              <p class="text-xs text-gray-500 dark:text-gray-400 mb-2">${aluno.data_cadastro}</p>
              ${aluno.status_badge}
              <button onclick="removerAlunoDaTurma(${aluno.id}, '${aluno.nome}', ${turmaId}, '${turmaNome}')" 
                      class="mt-3 w-full px-3 py-1.5 bg-red-500 text-white text-xs font-semibold rounded-lg hover:bg-red-600 transition-colors flex items-center justify-center gap-1.5 opacity-0 group-hover:opacity-100">
                <i class="fas fa-trash-alt"></i>
                Remover
              </button>
            </div>
          `).join('');
        }

        const modal = document.getElementById('alunos-modal');
        if (modal) {
          modal.classList.remove('hidden');
        }
      })
      .catch(error => {
        console.error('Erro ao carregar alunos:', error);
        alert('Erro ao carregar os alunos da turma');
      });
  };
  window.closeModal = function() {
    const modal = document.getElementById('alunos-modal');
    if (modal) {
      modal.classList.add('hidden');
    }
  };
  window.removerAlunoDaTurma = function(alunoId, alunoNome, turmaId, turmaNome) {
    const modal = document.getElementById('confirm-modal');
    const title = document.getElementById('confirm-title');
    const body = document.getElementById('confirm-body');
    const proceedBtn = document.getElementById('confirm-proceed');
    const cancelBtn = document.getElementById('confirm-cancel');
    
    if (!modal || !title || !body || !proceedBtn || !cancelBtn) {
      if (confirm(`Tem certeza que deseja remover "${alunoNome}" da turma "${turmaNome}"?`)) {
        executarRemocao(alunoId, turmaId, turmaNome);
      }
      return;
    }
    
    title.textContent = 'Remover Aluno da Turma';
    body.textContent = `Tem certeza que deseja remover "${alunoNome}" da turma "${turmaNome}"? O aluno não será excluído, apenas removido desta turma.`;
    
    modal.classList.remove('hidden');
    
    const handleProceed = () => {
      executarRemocao(alunoId, turmaId, turmaNome);
      modal.classList.add('hidden');
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
  };

  function executarRemocao(alunoId, turmaId, turmaNome) {
    fetch(`/turmas/${turmaId}/remover_aluno/${alunoId}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        'Content-Type': 'application/json'
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        const turmaElement = document.querySelector(`[data-turma-id="${turmaId}"]`);
        if (turmaElement) {
          abrirModalAlunos(turmaElement);
        }

        if (data.alunos_count !== undefined) {
          const cardTurma = document.querySelector(`[data-turma-id="${turmaId}"]`);
          if (cardTurma) {
            const contadorElement = cardTurma.querySelector('.font-semibold');
            if (contadorElement) {
              const textoAtual = contadorElement.textContent;
              const capacidade = textoAtual.split('/')[1]?.trim() || '0';
              contadorElement.textContent = `${data.alunos_count} / ${capacidade}`;
            }
          }
        }
      } else {
        alert(data.error || 'Erro ao remover aluno da turma');
      }
    })
    .catch(error => {
      console.error('Erro:', error);
      alert('Erro ao remover aluno da turma');
    });
  }
  const modalAlunos = document.getElementById('alunos-modal');
  if (modalAlunos) {
    modalAlunos.addEventListener('click', (e) => {
      if (e.target === modalAlunos) {
        closeModal();
      }
    });
  }
});