document.addEventListener('turbo:load', () => {
  console.log("✅ alunos_modal.js carregado");
  window.abrirModalAlunos = function (card) {
  const turmaId = card.dataset.turmaId;
  const turmaNome = card.dataset.turmaNome;

  const modal = document.getElementById("alunos-modal");
  const titulo = document.getElementById("modal-turma-nome");
  const container = document.getElementById("modal-alunos-container");

  if (!modal || !titulo || !container) {
    console.warn("Modal de alunos não encontrado na DOM.");
    return;
  }

  titulo.textContent = turmaNome || "Turma";
  container.innerHTML = `
    <div class="col-span-full text-center text-gray-400 py-6">
      <i class="fas fa-spinner fa-spin text-[#C5A300] text-2xl"></i>
      <p>Carregando alunos...</p>
    </div>`;
  fetch(`/turmas/${turmaId}/alunos`, { headers: { "Accept": "text/html" } })
    .then(response => {
      if (!response.ok) throw new Error("Erro na resposta");
      return response.text();
    })
    .then(html => {
      container.innerHTML = html;
      modal.classList.remove("hidden");
    })
    .catch(err => {
      console.error("Erro ao carregar alunos:", err);
      container.innerHTML = `<p class="text-red-500 col-span-full text-center">Erro ao carregar alunos.</p>`;
      modal.classList.remove("hidden");
    });
};

  window.closeModal = function () {
    const modal = document.getElementById("alunos-modal");
    if (modal) modal.classList.add("hidden");
  };
  const modal = document.getElementById("alunos-modal");
  if (modal) {
    modal.addEventListener("click", (e) => {
      if (e.target === modal) closeModal();
    });
  }
});
