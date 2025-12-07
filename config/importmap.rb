pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "confirm_modal"
pin "custom/theme_toggle"
pin "alunos_modal"
pin "configuracoes", to: "configuracoes.js"
pin "gerenciar_usuarios", to: "gerenciar_usuarios.js"
pin "gerenciar_alunos_turma", to: "gerenciar_alunos_turma.js"
pin "evento_form", to: "evento_form.js"

# Services 
pin "controllers/services/evento_service", to: "controllers/services/evento_service.js"
pin "controllers/services/mensalidade_service", to: "controllers/services/mensalidade_service.js"
pin "controllers/services/despesa_service", to: "controllers/services/despesa_service.js"
pin "controllers/services/extrato_service", to: "controllers/services/extrato_service.js"

# Mensalidade Modules
pin "controllers/services/mensalidade/ui_manager", to: "controllers/services/mensalidade/ui_manager.js"
pin "controllers/services/mensalidade/campo_manager", to: "controllers/services/mensalidade/campo_manager.js"
pin "controllers/services/mensalidade/api_manager", to: "controllers/services/mensalidade/api_manager.js"

# Helpers
pin "controllers/helpers/ui_helpers", to: "controllers/helpers/ui_helpers.js"
pin "controllers/helpers/form_helpers", to: "controllers/helpers/form_helpers.js"