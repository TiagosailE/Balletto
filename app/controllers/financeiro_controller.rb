# app/controllers/financeiro_controller.rb
class FinanceiroController < ApplicationController
  before_action :authenticate_user!

  def index
    # Dados gerais do financeiro (mantém o que já existia)
    @pagamentos = Pagamento.includes(:caixa, :aluno, :evento)
                           .order(pag_data: :desc)
                           
    @saldo_total = calcular_saldo_total
    @total_entradas = Pagamento.where(pag_tipo: 'Entrada').sum(:pag_valor)
    @total_saidas = Pagamento.where(pag_tipo: 'Saída').sum(:pag_valor)
    
    # Dados para a seção de Eventos
    @eventos = Evento.includes(:participantes_confirmados, :pagamentos)
                     .order(EVE_DATA: :desc)
    
    # Dados para a seção de Mensalidades
    @valor_mensalidade = Configuracao.valor_mensalidade
    @alunos = Aluno.order(:alu_nome)
    
    # Dados para os dropdowns de pagamento
    @caixas = Caixa.order(:cai_nome)
  end
  
  # Atualiza o valor do evento
  def atualizar_valor_evento
    evento = Evento.find(params[:evento_id])
    
    if evento.update(EVE_VALOR: params[:valor])
      render json: { success: true, valor_formatado: number_to_currency(evento.EVE_VALOR) }
    else
      render json: { success: false, errors: evento.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # Lista participantes confirmados de um evento
  def participantes_evento
    @caixas = Caixa.order(:cai_nome)
    
    evento = Evento.includes(participantes_confirmados: :foto_attachment).find(params[:evento_id])
    
    participantes = evento.participantes_confirmados.distinct.map do |aluno|
      pagamento = evento.pagamentos.find_by(aluno_id: aluno.alu_codigo)
      
      {
        id: aluno.alu_codigo,
        nome: aluno.alu_nome,
        foto_url: aluno.foto.attached? ? url_for(aluno.foto.variant(resize_to_fill: [48, 48])) : nil,
        pago: pagamento&.quitado? || false,
        pagamento_id: pagamento&.pag_codigo,
        valor_pago: pagamento&.pag_valor_pago || 0,
        valor_pendente: pagamento&.valor_pendente || evento.EVE_VALOR
      }
    end
    
    render json: { 
      evento: {
        id: evento.EVE_CODIGO,
        nome: evento.EVE_NOME,
        valor: evento.EVE_VALOR || 0
      },
      participantes: participantes,
      caixas: @caixas.map { |c| { id: c.cai_codigo, nome: c.cai_nome } }
    }
  rescue => e
    render json: { 
      success: false, 
      error: "Erro ao carregar participantes: #{e.message}" 
    }, status: :internal_server_error
  end
  
  # Registra pagamento de participante do evento
  def registrar_pagamento_evento
    evento = Evento.find(params[:evento_id])
    aluno = Aluno.find(params[:aluno_id])
    valor_pago = BigDecimal(params[:valor_pago] || '0')
    
    # Verifica se já existe um pagamento para esse aluno nesse evento
    pagamento = evento.pagamentos.find_by(aluno_id: aluno.alu_codigo)
    
    if pagamento
      # Atualiza o pagamento existente (adiciona ao valor já pago)
      pagamento.pag_valor_pago = (pagamento.pag_valor_pago || 0) + valor_pago
      pagamento.save
    else
      # Cria novo pagamento
      pagamento = Pagamento.new(
        caixa_id: params[:caixa_id],
        aluno_id: aluno.alu_codigo,
        evento_id: evento.EVE_CODIGO,
        pag_data: Time.current,
        pag_valor: evento.EVE_VALOR,
        pag_valor_pago: valor_pago,
        pag_descricao: "Pagamento - #{evento.EVE_NOME}",
        pag_tipo: 'Entrada',
        pag_metodo: params[:metodo] || 'Dinheiro'
      )
      pagamento.save
    end
    
    if pagamento.persisted?
      render json: { 
        success: true, 
        message: pagamento.quitado? ? 'Pagamento quitado!' : "Pagamento registrado! Faltam #{number_to_currency(pagamento.valor_pendente)}",
        pagamento_id: pagamento.pag_codigo,
        valor_pendente: pagamento.valor_pendente,
        quitado: pagamento.quitado?
      }
    else
      render json: { 
        success: false, 
        errors: pagamento.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end
  
  # Atualiza o valor padrão da mensalidade
  def atualizar_valor_mensalidade
    if Configuracao.set_valor_mensalidade(params[:valor])
      render json: { 
        success: true, 
        valor_formatado: number_to_currency(BigDecimal(params[:valor])) 
      }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end
  
  # Registra pagamento de mensalidade
  def registrar_pagamento_mensalidade
    aluno = Aluno.find(params[:aluno_id])
    valor_total = params[:valor_total] || Configuracao.valor_mensalidade
    valor_pago = BigDecimal(params[:valor_pago] || '0')
    mes_referencia = params[:mes_referencia] || Date.current.strftime('%m/%Y')
    
    # Verifica se já existe pagamento de mensalidade para esse mês
    pagamento = Pagamento.find_by(
      aluno_id: aluno.alu_codigo,
      pag_descricao: "Mensalidade - #{mes_referencia}"
    )
    
    if pagamento
      # Atualiza o pagamento existente
      pagamento.pag_valor_pago = (pagamento.pag_valor_pago || 0) + valor_pago
      pagamento.save
    else
      # Cria novo pagamento
      pagamento = Pagamento.new(
        caixa_id: params[:caixa_id],
        aluno_id: aluno.alu_codigo,
        pag_data: Time.current,
        pag_valor: valor_total,
        pag_valor_pago: valor_pago,
        pag_descricao: "Mensalidade - #{mes_referencia}",
        pag_tipo: 'Entrada',
        pag_metodo: params[:metodo] || 'Dinheiro'
      )
      pagamento.save
    end
    
    if pagamento.persisted?
      render json: { 
        success: true, 
        message: pagamento.quitado? ? 'Mensalidade quitada!' : "Pagamento registrado! Faltam #{number_to_currency(pagamento.valor_pendente)}"
      }
    else
      render json: { 
        success: false, 
        errors: pagamento.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end
  
def registrar_despesa
  pagamento = Pagamento.new(
    caixa_id: params[:caixa_id],
    pag_data: Time.current,
    pag_valor: params[:valor],
    pag_descricao: params[:descricao],
    pag_tipo: 'Saída',
    pag_status: 'Pago',
    pag_metodo: params[:metodo] || 'Dinheiro'
  )
  
  if pagamento.save
    render json: { 
      success: true, 
      message: 'Despesa registrada com sucesso!' 
    }
  else
    render json: { 
      success: false, 
      errors: pagamento.errors.full_messages 
    }, status: :unprocessable_entity
  end
end
  
  private
  
  def calcular_saldo_total
    Caixa.sum("cai_saldo_inicial") + 
    Pagamento.where(pag_tipo: 'Entrada').sum(:pag_valor) - 
    Pagamento.where(pag_tipo: 'Saída').sum(:pag_valor)
  end
  
  include ActionView::Helpers::NumberHelper
end