import "@hotwired/turbo-rails"
import "controllers"
import "confirm_modal"
import "custom/theme_toggle"
import "alunos_modal"
import "configuracoes"
import "gerenciar_usuarios"
import "gerenciar_alunos_turma"
import "evento_form"

function fadeFlashMessages() {
  const flashes = document.querySelectorAll(".animate-fade-in-down");

  flashes.forEach(flash => {
    setTimeout(() => {
      flash.style.transition = "opacity 0.6s ease, transform 0.6s ease";
      flash.style.opacity = "0";
      flash.style.transform = "translateY(-10px)";

      setTimeout(() => flash.remove(), 600);
    }, 2500);
  });
}

document.addEventListener("turbo:load", fadeFlashMessages);
document.addEventListener("turbo:render", fadeFlashMessages);