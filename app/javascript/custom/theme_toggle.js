// Função para alternar o tema
function handleThemeToggle() {
  // Se tiver a classe dark, muda para light
  if (document.documentElement.classList.contains('dark')) {
    document.documentElement.classList.remove('dark')
    localStorage.theme = 'light'
  } else {
    // Se não tiver a classe dark, muda para dark
    document.documentElement.classList.add('dark')
    localStorage.theme = 'dark'
  }
}

// Função para configurar o botão
function setupThemeToggle() {
  const button = document.getElementById('theme-toggle')
  if (button) {
    button.addEventListener('click', handleThemeToggle)
  }
}

// Configurar o botão quando o DOM carregar
document.addEventListener('DOMContentLoaded', setupThemeToggle)

// Reconfigurar o botão após navegação com Turbo
document.addEventListener('turbo:load', setupThemeToggle)