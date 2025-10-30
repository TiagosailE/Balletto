# 📘 Projeto Rails

Este projeto utiliza Ruby on Rails para desenvolvimento web. Abaixo estão as instruções básicas para configurar e iniciar o ambiente de desenvolvimento.

---

## 🚀 Versões

- **Ruby**: 3.4.7  
- **Rails**: 8.0.3  

---

## ⚙️ Inicialização do Projeto

Para iniciar o ambiente de desenvolvimento com o Foreman:

```bash
foreman start -f Procfile.dev
```

---

## 🛠️ Console Rails

Para acessar o console do Rails, utilize:

```bash
rails console
```

Criação de um usuário administrador:

```ruby
User.create!(
  nome: 'Admin Host',
  usuario: 'admin',
  email: 'admin@exemplo.com',
  password: '123456',
  password_confirmation: '123456',
  role: :admin
)
```

---