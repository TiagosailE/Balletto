document.addEventListener('turbo:load', () => {
  console.log("⚡ alunos_modal.js (versão fotos) carregado");

  // -----------------------------
  // 1. CACHE DE ELEMENTOS
  // -----------------------------
  const $ = (sel) => document.querySelector(sel);

  const modalAlunos     = $("#alunos-modal");
  const modalTurmas     = $("#modal-turmas-evento");
  const modalTurmasContent = $("#modal-content");
  const turmasList      = $("#turmas-list");
  const modalAlunosEvento  = $("#modal-alunos-evento");
  const modalAlunosEventoContent = $("#modal-alunos-content");
  const alunosList      = $("#alunos-list");
  const turmaNomeHeader   = $("#turma-nome-header");
  const alunosConfirmadosCount = $('#alunos-confirmados-count');

  // -----------------------------
  // 2. ESTADO GLOBAL
  // -----------------------------
  const state = {
    eventoId: null,
    turmaId: null
  };

  // -----------------------------
  // 3. FUNÇÕES AUXILIARES
  // -----------------------------

  const formatarHorario = (h) => {
    if (!h) return "";
    const d = new Date(h);
    if (!isNaN(d)) return `${String(d.getUTCHours()).padStart(2, "0")}:${String(d.getUTCMinutes()).padStart(2, "0")}`;
    const match = h.match(/(\d{2}):(\d{2})/);
    return match ? `${match[1]}:${match[2]}` : h;
  };

  const atualizarContadorAlunos = () => {
    if (!alunosList) return;
    const n = alunosList.querySelectorAll(".custom-checkbox:checked").length;
    if (alunosConfirmadosCount) {
      alunosConfirmadosCount.textContent = `${n} aluno${n === 1 ? "" : "s"} confirmado${n === 1 ? "" : "s"}`;
    }
  };

  // -----------------------------
  // 4. MODAL TURMAS
  // -----------------------------

  window.abrirModalTurmas = async (eventoId) => {
    state.eventoId = eventoId;
    modalTurmas.classList.remove("hidden");

    requestAnimationFrame(() => {
      modalTurmasContent.classList.remove("scale-95", "opacity-0");
      modalTurmasContent.classList.add("scale-100", "opacity-100");
    });

    turmasList.innerHTML = `<div class="text-center text-gray-400 py-12"><i class="fas fa-spinner fa-spin text-4xl"></i></div>`;

    try {
      const res = await fetch(`/eventos/${eventoId}/turmas`);
      const data = await res.json();

      if (!data.length) {
        turmasList.innerHTML = `
          <div class="text-center py-12">
            <i class="fas fa-inbox text-5xl text-gray-300 mb-4"></i>
            <p class="text-gray-500 text-lg">Nenhuma turma vinculada.</p>
          </div>`;
        return;
      }

      const html = [];
      for (const turma of data) {
        html.push(`
          <div class="turma-card p-5 rounded-xl border-2 cursor-pointer transition-all
               border-gray-200 dark:border-[#2E2E2E] 
               bg-gray-50 dark:bg-[#111111]"
               data-turma-id="${turma.tur_codigo}"
               data-turma-nome="${turma.tur_nome.replace(/"/g, "&quot;")}">

            <div class="flex justify-between mb-3">
              <h4 class="font-bold text-lg text-[#B88B00] dark:text-[#C5A300]">${turma.tur_nome}</h4>
              <i class="fas fa-chevron-right text-[#C5A300]"></i>
            </div>

            <div class="space-y-1 text-gray-600 dark:text-gray-400">
              ${turma.tur_dia_da_semana ? `<div>${turma.tur_dia_da_semana}</div>` : ""}
              ${turma.tur_horario ? `<div>${formatarHorario(turma.tur_horario)}</div>` : ""}
            </div>

            <div class="mt-3 text-xs text-gray-500">Clique para ver alunos</div>
          </div>
        `);
      }

      turmasList.innerHTML = `<div class="grid grid-cols-1 md:grid-cols-2 gap-4">${html.join("")}</div>`;

    } catch (err) {
      console.error(err);
      turmasList.innerHTML = `<div class="text-center py-12"><p class="text-red-500 text-lg">Erro ao carregar turmas.</p></div>`;
    }
  };

  window.fecharModalTurmas = () => {
    modalTurmasContent.classList.remove("scale-100", "opacity-100");
    modalTurmasContent.classList.add("scale-95", "opacity-0");
    setTimeout(() => modalTurmas.classList.add("hidden"), 180);
  };

  // -----------------------------
  // 5. MODAL ALUNOS (COM FOTOS ✨)
  // -----------------------------

  window.abrirModalAlunosEvento = async (turmaId, turmaNome) => {
    state.turmaId = turmaId;

    turmaNomeHeader.textContent = turmaNome;
    modalAlunosEvento.classList.remove("hidden");

    requestAnimationFrame(() => {
      modalAlunosEventoContent.classList.remove("scale-95", "opacity-0");
      modalAlunosEventoContent.classList.add("scale-100", "opacity-100");
    });

    alunosList.innerHTML = `<div class="text-center text-gray-400 py-8"><i class="fas fa-spinner fa-spin text-2xl"></i></div>`;

    try {
      const res = await fetch(`/eventos/${state.eventoId}/turmas/${turmaId}/alunos`);
      const alunos = await res.json();

      if (!alunos.length) {
        alunosList.innerHTML = `<div class="text-center py-12"><p class="text-gray-500 text-lg">Nenhum aluno matriculado.</p></div>`;
        atualizarContadorAlunos();
        return;
      }

      // --- ✨ ESTA É A LÓGICA DAS FOTOS ---
      const html = alunos.map(a => `
        <div class="flex items-center justify-between p-4 border-2 rounded-xl 
             border-gray-200 dark:border-[#2E2E2E] 
             bg-gray-50 dark:bg-[#111111]">
          
          <div class="flex items-center gap-3">
            
            ${a.foto_url
              // Se tiver foto_url, usa <img>
              ? `<img src="${a.foto_url}" class="w-11 h-11 rounded-full object-cover">`
              
              // Se não, usa a inicial (com texto preto na cor dourada)
              : `<div class="w-11 h-11 rounded-full bg-[#C5A300] text-black flex items-center justify-center font-bold text-lg">
                   ${a.nome[0].toUpperCase()}
                 </div>`
            }
            <span class="font-medium text-gray-800 dark:text-gray-200">${a.nome}</span>
          </div>
          
          <input type="checkbox" class="custom-checkbox"
                 data-aluno-id="${a.id}"
                 ${a.confirmado ? "checked" : ""}>
        </div>
      `).join("");

      alunosList.innerHTML = html;
      atualizarContadorAlunos();

    } catch (err) {
      alunosList.innerHTML = `<p class="text-red-500">Erro ao carregar alunos.</p>`;
    }
  };

  window.fecharModalAlunosEvento = () => {
    modalAlunosEventoContent.classList.remove("scale-100", "opacity-100");
    modalAlunosEventoContent.classList.add("scale-95", "opacity-0");
    setTimeout(() => modalAlunosEvento.classList.add("hidden"), 180);
  };

  // -----------------------------
  // 6. TOGGLE ALUNO
  // -----------------------------
  window.toggleAlunoEvento = async (id, checkbox) => {
    const token = document.querySelector('[name="csrf-token"]')?.content;
    if (!token) return;

    try {
      const res = await fetch(
        `/eventos/${state.eventoId}/turmas/${state.turmaId}/alunos/${id}/toggle`,
        { method: "POST", headers: { "X-CSRF-Token": token } }
      );

      const json = await res.json();
      checkbox.checked = json.confirmado;
      atualizarContadorAlunos();

    } catch (err) {
      checkbox.checked = !checkbox.checked;
      alert("Erro ao atualizar aluno.");
    }
  };

  // -----------------------------
  // 7. DELEGAÇÃO DE EVENTOS
  // -----------------------------

  turmasList?.addEventListener("click", (e) => {
    const card = e.target.closest(".turma-card");
    if (!card) return;
    abrirModalAlunosEvento(card.dataset.turmaId, card.dataset.turmaNome);
  });

  alunosList?.addEventListener("change", (e) => {
    if (!e.target.classList.contains("custom-checkbox")) return;
    toggleAlunoEvento(e.target.dataset.alunoId, e.target);
  });

  // -----------------------------
  // 8. FECHAR MODAIS VIA BACKDROP
  // -----------------------------
  modalTurmas?.addEventListener("click", (e) => e.target === modalTurmas && fecharModalTurmas());
  modalAlunosEvento?.addEventListener("click", (e) => e.target === modalAlunosEvento && fecharModalAlunosEvento());
});