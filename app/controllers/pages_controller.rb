class PagesController < ApplicationController
  before_action :authenticate_user!

  def home
    @total_alunos = Aluno.count
  end
end