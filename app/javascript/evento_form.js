document.addEventListener('turbo:load', initEventoForm);
document.addEventListener('turbo:render', initEventoForm);

function initEventoForm() {
  console.log('Evento form inicializado');

  const dateInput = document.querySelector('input[type="datetime-local"]');
  if (dateInput) {
    dateInput.addEventListener('input', limitarAno);
  }

  initTurmaSelector();

  initDescriptionCounter();
}

function limitarAno(event) {
  const input = event.target;
  if (input.value) {
    const parts = input.value.split('T');
    const [year, month, day] = parts[0].split('-');
    if (year && year.length > 4) {
      const novoAno = year.slice(0, 4);
      input.value = `${novoAno}-${month}-${day}T${parts[1] || '00:00'}`;
    }
  }
}

function initTurmaSelector() {
  const selector = document.getElementById('turma-selector');
  if (!selector) {
    console.log('Seletor de turmas não encontrado');
    return;
  }

  console.log('Inicializando seletor de turmas');

  const searchInput = document.getElementById('turma-search');
  const turmaList = document.getElementById('turma-list');
  const selectedContainer = document.getElementById('selected-turmas');
  const selectAllBtn = document.getElementById('select-all-turmas');
  const clearAllBtn = document.getElementById('clear-all-turmas');

  console.log('Botão selecionar todas:', selectAllBtn);
  console.log('Botão limpar todas:', clearAllBtn);

  if (searchInput) {
    searchInput.addEventListener('input', function(e) {
      const searchTerm = e.target.value.toLowerCase();
      const turmaItems = turmaList.querySelectorAll('.turma-item');

      turmaItems.forEach(item => {
        const turmaName = item.dataset.turmaName.toLowerCase();
        if (turmaName.includes(searchTerm)) {
          item.style.display = '';
        } else {
          item.style.display = 'none';
        }
      });
    });
  }

  if (turmaList) {
    turmaList.addEventListener('click', function(e) {
      const turmaItem = e.target.closest('.turma-item');
      if (!turmaItem) return;

      const checkbox = turmaItem.querySelector('input[type="checkbox"]');
      if (e.target !== checkbox) {
        checkbox.checked = !checkbox.checked;
      }

      updateTurmaSelection(turmaItem, checkbox.checked);
      updateSelectedDisplay();
    });
  }

  if (selectAllBtn) {

    const newSelectAllBtn = selectAllBtn.cloneNode(true);
    selectAllBtn.parentNode.replaceChild(newSelectAllBtn, selectAllBtn);
    
    newSelectAllBtn.addEventListener('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      
      console.log('Clicou em selecionar todas');
      
      const turmaItems = document.querySelectorAll('.turma-item');
      console.log('Total de turmas:', turmaItems.length);
      
      turmaItems.forEach(item => {
        if (item.style.display !== 'none') {
          const checkbox = item.querySelector('input[type="checkbox"]');
          if (checkbox && !checkbox.checked) {
            checkbox.checked = true;
            updateTurmaSelection(item, true);
          }
        }
      });
      
      updateSelectedDisplay();
      console.log('Todas as turmas selecionadas');
    });
  }

  if (clearAllBtn) {

    const newClearAllBtn = clearAllBtn.cloneNode(true);
    clearAllBtn.parentNode.replaceChild(newClearAllBtn, clearAllBtn);
    
    newClearAllBtn.addEventListener('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      
      console.log('Clicou em limpar todas');
      
      const turmaItems = document.querySelectorAll('.turma-item');
      console.log('Total de turmas:', turmaItems.length);
      
      turmaItems.forEach(item => {
        const checkbox = item.querySelector('input[type="checkbox"]');
        if (checkbox && checkbox.checked) {
          checkbox.checked = false;
          updateTurmaSelection(item, false);
        }
      });
      
      updateSelectedDisplay();

      if (searchInput) {
        searchInput.value = '';
        turmaItems.forEach(item => item.style.display = '');
      }
      
      console.log('Todas as turmas desmarcadas');
    });
  }

  if (selectedContainer) {
    selectedContainer.addEventListener('click', function(e) {
      const removeBtn = e.target.closest('.remove-turma');
      if (!removeBtn) return;
      
      e.preventDefault();
      e.stopPropagation();
      
      const badge = removeBtn.closest('.selected-turma-badge');
      const turmaId = badge.dataset.turmaId;

      const checkbox = document.querySelector(`#turma_${turmaId}`);
      if (checkbox) {
        checkbox.checked = false;
        const turmaItem = checkbox.closest('.turma-item');
        updateTurmaSelection(turmaItem, false);
      }
      
      updateSelectedDisplay();
    });
  }

  updateSelectedDisplay();
}

function updateTurmaSelection(turmaItem, isSelected) {
  if (isSelected) {
    turmaItem.classList.add('bg-[#C5A300]', 'bg-opacity-10', 'border-[#C5A300]');
    turmaItem.classList.remove('border-gray-200', 'dark:border-[#2E2E2E]');
  } else {
    turmaItem.classList.remove('bg-[#C5A300]', 'bg-opacity-10', 'border-[#C5A300]');
    turmaItem.classList.add('border-gray-200', 'dark:border-[#2E2E2E]');
  }
}

function updateSelectedDisplay() {
  const selectedContainer = document.getElementById('selected-turmas');
  if (!selectedContainer) return;

  const selectedCheckboxes = document.querySelectorAll('.turma-checkbox:checked');

  selectedContainer.innerHTML = '';

  selectedCheckboxes.forEach(checkbox => {
    const turmaItem = checkbox.closest('.turma-item');
    const turmaName = turmaItem.dataset.turmaName;
    const turmaId = checkbox.value;

    const badge = createTurmaBadge(turmaId, turmaName);
    selectedContainer.appendChild(badge);
  });
}

function createTurmaBadge(turmaId, turmaName) {
  const badge = document.createElement('div');
  badge.className = 'selected-turma-badge inline-flex items-center gap-2 bg-[#C5A300] text-black font-semibold px-3 py-1.5 rounded-full text-sm';
  badge.dataset.turmaId = turmaId;
  
  badge.innerHTML = `
    <span>${turmaName}</span>
    <button type="button" class="remove-turma hover:bg-black hover:bg-opacity-20 rounded-full p-0.5 transition-colors">
      <i class="fas fa-times text-xs"></i>
    </button>
  `;
  
  return badge;
}

function initDescriptionCounter() {
  const textarea = document.querySelector('textarea[maxlength="300"]');
  const counter = document.getElementById('desc-count');
  
  if (textarea && counter) {
    textarea.addEventListener('input', function() {
      counter.textContent = `${this.value.length}/300`;
    });
  }
}