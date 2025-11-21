function openConfirmModal({ title, body, confirmPath, confirmText = 'Excluir', confirmClass = 'bg-red-600' }) {
  const modal = document.getElementById('confirm-modal');
  if (!modal) return;

  const modalTitle = document.getElementById('confirm-title');
  const modalBody = document.getElementById('confirm-body');
  const cancelButton = document.getElementById('confirm-cancel');
  
  let proceedButton = document.getElementById('confirm-proceed');
  proceedButton.replaceWith(proceedButton.cloneNode(true));
  proceedButton = document.getElementById('confirm-proceed'); 

  modalTitle.textContent = title;
  modalBody.textContent = body;
  proceedButton.textContent = confirmText;
  
  proceedButton.className = `px-6 py-2 rounded-md transition-all text-white ${confirmClass}`;

  modal.classList.remove('hidden');
  modal.classList.add('flex');

  const closeAndCleanup = () => {
    modal.classList.add('hidden');
    modal.classList.remove('flex');
  };

  const proceedAction = () => {
    const form = document.createElement('form');
    form.method = 'post';
    form.action = confirmPath;
    form.style.display = 'none';

    const methodInput = document.createElement('input');
    methodInput.type = 'hidden';
    methodInput.name = '_method';
    methodInput.value = 'delete';
    form.appendChild(methodInput);

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
    if (csrfToken) {
      const csrfInput = document.createElement('input');
      csrfInput.type = 'hidden';
      csrfInput.name = 'authenticity_token';
      csrfInput.value = csrfToken;
      form.appendChild(csrfInput);
    } else {
      console.error("CSRF token não encontrado. A exclusão foi abortada.");
      return;
    }

    document.body.appendChild(form);
    form.requestSubmit();
    document.body.removeChild(form);

    closeAndCleanup();
  };

  cancelButton.addEventListener('click', closeAndCleanup, { once: true });
  proceedButton.addEventListener('click', proceedAction, { once: true });
}

document.addEventListener("turbo:load", () => {
  document.querySelectorAll('[data-confirm-modal]').forEach(button => {
    const newButton = button.cloneNode(true);
    button.parentNode.replaceChild(newButton, button);
    
    newButton.addEventListener('click', (event) => {
      event.preventDefault();
      event.stopPropagation();
      
      openConfirmModal({
        title: newButton.dataset.confirmTitle,
        body: newButton.dataset.confirmBody,
        confirmPath: newButton.dataset.confirmPath,
        confirmText: newButton.dataset.confirmText,
        confirmClass: newButton.dataset.confirmClass
      });
    });
  });
});

window.openConfirmModal = openConfirmModal;