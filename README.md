# 📘 Projeto Balletto

Este projeto utiliza **Ruby on Rails** para desenvolvimento web. Abaixo estão as instruções básicas para configurar e iniciar o ambiente de desenvolvimento.

-----

## 🚀 Versões

  * **Ruby**: 3.4.7
  * **Rails**: 8.0.3

-----

## 🗄️ Configuração do Banco de Dados (PostgreSQL)

Para garantir a **segurança** e a **portabilidade** das credenciais, o projeto utiliza variáveis de ambiente lidas pelo arquivo local **`.env`**.

### 1\. Preparação dos Arquivos

1.  No diretório raiz do projeto, você encontrará o arquivo **modelo** para as variáveis:
    ```
    .env.example
    ```
2.  Crie uma **cópia** deste arquivo e renomeie-o para **`.env`**:
    ```bash
    cp .env.example .env
    ```

### 2\. Configuração de Credenciais

Abra o novo arquivo **`.env`** e substitua os `*****` pelas suas credenciais **locais** do PostgreSQL:

```bash
# Arquivo: .env

# Credenciais Locais (para o ambiente 'development')
DB_USERNAME=seu_usuario_postgres
DB_PASSWORD=sua_senha_postgres
```

⚠️ **Importante:**

  * O arquivo **`.env`** está configurado para ser **ignorado pelo Git** (`.gitignore`), garantindo que suas senhas locais não sejam versionadas.
  * As credenciais precisam corresponder ao usuário configurado no seu PostgreSQL. O usuário padrão costuma ser `postgres` ou seu nome de usuário do sistema.

-----

## ⚙️ Inicialização do Projeto

Para iniciar o ambiente de desenvolvimento, utilize o Foreman, que garante que todos os processos (servidor web, CSS watcher, etc.) iniciem corretamente:

```bash
foreman start -f Procfile.dev
```

*(O comando `rails s` só iniciará o servidor web e não incluirá dependências como o watcher de CSS.)*

-----

## 🛠️ Console Rails

Para acessar o console do Rails, utilize:

```bash
rails console
```

Criação de um usuário administrador:

```ruby
rails db:seed
```

-----

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

1.  Acesse [libvips.org/install](https://libvips.org/install.html).
2.  Baixe o arquivo `vips-dev-w64-web-x.y.z.zip` (versão mais recente).
3.  Extraia o conteúdo em uma pasta de sua preferência.
4.  Adicione o caminho da pasta `vips-x.y.z/bin` às variáveis de ambiente (`PATH`).
5.  Teste a instalação com:

<!-- end list -->

```bash
vips.exe --version
```