class PagesController < ApplicationController
  before_action :authenticate_user!

  def home
    # Pega a tabela de Eventos usando Arel
    t = Evento.arel_table

    @eventos = Evento.order(t[:EVE_CODIGO].desc).limit(3)
  end
end