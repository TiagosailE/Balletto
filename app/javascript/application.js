import "@hotwired/turbo-rails"
import "controllers"
import "confirm_modal"
import "custom/theme_toggle"
import "alunos_modal"
import "configuracoes"
import "gerenciar_usuarios"
import "gerenciar_alunos_turma"

// --- Lógica Global de UI ---

// Animação de fade-out para mensagens flash (Alertas/Notificações)
document.addEventListener("turbo:load", () => {
  const flashes = document.querySelectorAll(".animate-fade-in-down");

  flashes.forEach(flash => {
    // Aguarda 2.5 segundos antes de começar a sumir
    setTimeout(() => {
      flash.style.transition = "opacity 0.6s ease, transform 0.6s ease";
      flash.style.opacity = "0";
      flash.style.transform = "translateY(-10px)";
      
      // Remove do DOM após a animação terminar
      setTimeout(() => flash.remove(), 600);
    }, 2500); 
  });
});