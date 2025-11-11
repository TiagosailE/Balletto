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

## 🖼️ Dependência: libvips-dev

Este projeto utiliza a biblioteca **libvips** para processamento eficiente de imagens. Ela é mais rápida e consome menos memória que alternativas como ImageMagick, sendo ideal para aplicações web que manipulam imagens.

### 🔧 Instalação no Linux

Para sistemas baseados em Debian/Ubuntu:

```bash
sudo apt update
sudo apt install libvips-dev
```

Para sistemas baseados em Fedora:

```bash
sudo dnf install vips-devel
```

Para Arch Linux:

```bash
sudo pacman -S vips
```

### 🪟 Instalação no Windows

No Windows, é necessário baixar os binários pré-compilados:

1. Acesse [libvips.org/install](https://libvips.org/install.html).
2. Baixe o arquivo `vips-dev-w64-web-x.y.z.zip` (versão mais recente).
3. Extraia o conteúdo em uma pasta de sua preferência.
4. Adicione o caminho da pasta `vips-x.y.z/bin` às variáveis de ambiente (`PATH`).
5. Teste a instalação com:

```bash
vips.exe --version
```