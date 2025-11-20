module ApplicationHelper
  # Mudamos a assinatura para aceitar um hash genérico 'options' no final
  def tailwind_field(form, attribute, label_text, icon_class, options = {})
    
    # 1. Extraímos as configurações especiais e removemos do hash (para não virar atributo HTML)
    field_type = options.delete(:field_type) || :text_field
    placeholder = options.delete(:placeholder)
    wrapper_class = options.delete(:wrapper_class)
    
    # 2. Define se tem erro para mudar a cor da borda
    has_error = form.object.errors[attribute].any?
    border_class = has_error ? 
      'border-red-600 ring-1 ring-red-600' : 
      'border-gray-300 dark:border-[#2E2E2E] focus-within:border-[#C5A300] focus-within:ring-2 focus-within:ring-[#C5A300]'

    # 3. Classes padrão dos inputs + classes extras que vierem no options
    input_classes = "block w-full bg-transparent text-gray-900 dark:text-[#E5E5E5] rounded-lg pl-2.5 pr-4 py-3 placeholder-gray-400 dark:placeholder-gray-500 border-none focus:outline-none focus:ring-0 #{options.delete(:class)}"
    
    # 4. Renderiza o HTML
    content_tag :div, class: wrapper_class do
      concat form.label attribute, label_text, class: "flex items-center text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5"
      
      concat(content_tag(:div, class: "flex items-center bg-gray-50 dark:bg-[#0A0A0A] rounded-lg border transition-colors duration-200 #{border_class}") do
        concat(content_tag(:div, class: "pl-3.5 flex items-center pointer-events-none") do
          content_tag(:i, nil, class: "fas #{icon_class} w-5 text-center text-gray-400 dark:text-gray-500")
        end)
        
        # Aqui passamos o 'options' restante, que pode conter eventos JS, data-attributes, etc.
        concat form.send(field_type, attribute, options.merge(class: input_classes, placeholder: placeholder))
      end)

      # Mostra mensagem de erro se houver
      if has_error
        concat content_tag(:p, form.object.errors.full_messages_for(attribute).first, class: "text-red-500 dark:text-red-400 text-xs mt-1")
      end
    end
  end
end