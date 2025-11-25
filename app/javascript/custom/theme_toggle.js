function handleThemeToggle() {
  if (document.documentElement.classList.contains('dark')) {
    document.documentElement.classList.remove('dark')
    localStorage.theme = 'light'
  } else {
    document.documentElement.classList.add('dark')
    localStorage.theme = 'dark'
  }
}

function setupThemeToggle() {
  const button = document.getElementById('theme-toggle')
  if (!button) return
  
  // evita múltiplos addEventListener duplicados
  button.removeEventListener('click', handleThemeToggle)
  button.addEventListener('click', handleThemeToggle)
}

document.addEventListener('turbo:load', setupThemeToggle)
document.addEventListener('turbo:render', setupThemeToggle)
