console.log("✅ turmas.js carregado");

function openModal(turmaNome) {
  const modal = document.getElementById('alunos-modal');
  const turmaTitle = document.getElementById('modal-turma-nome');
  turmaTitle.textContent = turmaNome;
  modal.classList.remove('hidden');
  modal.classList.add('flex');
}

function closeModal() {
  const modal = document.getElementById('alunos-modal');
  modal.classList.add('hidden');
  modal.classList.remove('flex');
}

window.openModal = openModal;
window.closeModal = closeModal;

document.addEventListener("turbo:load", () => {
  const modal = document.getElementById('alunos-modal');
  modal?.addEventListener("click", (e) => {
    if (e.target === modal) closeModal();
  });

  console.log("✅ Listeners do modal configurados");
});