class FinanceiroController < ApplicationController
  before_action :authenticate_user!

  def index

    @pagamentos = Pagamento.includes(:caixa, :aluno, :evento)
                           .order(pag_data: :desc)
                           
    @saldo_total = calcular_saldo_total
    @total_entradas = Pagamento.where(pag_tipo: 'Entrada').sum(:pag_valor)
    @total_saidas = Pagamento.where(pag_tipo: 'Saída').sum(:pag_valor)

    @eventos = Evento.includes(:participantes_confirmados, :pagamentos)
                     .order(EVE_DATA: :desc)

    @valor_mensalidade = Configuracao.valor_mensalidade
    @alunos = Aluno.order(:alu_nome)

    @caixas = Caixa.order(:cai_nome)
  end

  def atualizar_valor_evento
    evento = Evento.find(params[:evento_id])
    
    if evento.update(EVE_VALOR: params[:valor])
      render json: { success: true, valor_formatado: number_to_currency(evento.EVE_VALOR) }
    else
      render json: { success: false, errors: evento.errors.full_messages }, status: :unprocessable_entity
    end
  end

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

  def registrar_pagamento_evento
    evento = Evento.find(params[:evento_id])
    aluno = Aluno.find(params[:aluno_id])
    valor_pago = BigDecimal(params[:valor_pago] || '0')
    pagamento = evento.pagamentos.find_by(aluno_id: aluno.alu_codigo)
    
    if pagamento
      pagamento.pag_valor_pago = (pagamento.pag_valor_pago || 0) + valor_pago
      pagamento.save
    else
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

  def registrar_pagamento_mensalidade
    aluno = Aluno.find(params[:aluno_id])
    valor_total = params[:valor_total] || Configuracao.valor_mensalidade
    valor_pago = BigDecimal(params[:valor_pago] || '0')
    mes_referencia = params[:mes_referencia] || Date.current.strftime('%m/%Y')

    pagamento = Pagamento.find_by(
      aluno_id: aluno.alu_codigo,
      pag_descricao: "Mensalidade - #{mes_referencia}"
    )
    
    if pagamento
      pagamento.pag_valor_pago = (pagamento.pag_valor_pago || 0) + valor_pago
      pagamento.save
    else
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

def extrato
  transacoes = Pagamento.includes(:caixa, :aluno, :evento)
    .order(pag_data: :desc)
    .limit(50)
    .map do |t|
      tipo_transacao = t.pag_tipo == 'Entrada' ? 'receita' : 'despesa'
      
      categoria_info = if t.evento.present?
        { 
          categoria: t.evento.EVE_NOME,
          categoria_icone: 'fas fa-calendar-check',
          categoria_classe: 'bg-purple-100 dark:bg-purple-900/30 text-purple-800 dark:text-purple-300'
        }
      elsif t.pag_descricao&.include?('Mensalidade')
        { 
          categoria: 'Mensalidade',
          categoria_icone: 'fas fa-money-bill-wave',
          categoria_classe: 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300'
        }
      elsif t.pag_tipo == 'Saída'
        { 
          categoria: 'Despesa',
          categoria_icone: 'fas fa-arrow-down',
          categoria_classe: 'bg-red-100 dark:bg-red-900/30 text-red-800 dark:text-red-300'
        }
      else
        { 
          categoria: 'Entrada',
          categoria_icone: 'fas fa-file-invoice',
          categoria_classe: 'bg-gray-100 dark:bg-gray-900/30 text-gray-800 dark:text-gray-300'
        }
      end
      
      {
        tipo: tipo_transacao,
        descricao: t.pag_descricao.presence || "Lançamento",
        valor: t.pag_valor,
        metodo: t.pag_metodo,
        caixa: t.caixa.cai_nome,
        data: t.pag_data.in_time_zone('America/Sao_Paulo').strftime('%d/%m/%Y %H:%M'),
        status: t.pag_status,
        associado: t.aluno.present? ? "<i class='fas fa-user-graduate w-4 text-center mr-1 text-[#C5A300]'></i>#{t.aluno.alu_nome}" : (t.evento.present? ? "<i class='fas fa-calendar-check w-4 text-center mr-1 text-purple-500'></i>#{t.evento.EVE_NOME}" : nil)
      }.merge(categoria_info)
    end

  total_entradas = Pagamento.where(pag_tipo: 'Entrada').sum(:pag_valor)
  total_saidas = Pagamento.where(pag_tipo: 'Saída').sum(:pag_valor)
  saldo = Caixa.sum("cai_saldo_inicial") + total_entradas - total_saidas
  
  totais = {
    total_receitas: total_entradas,
    total_despesas: total_saidas,
    saldo: saldo
  }
  
  render json: { transacoes: transacoes, totais: totais }
end

def info_mensalidade_aluno
  aluno = Aluno.find(params[:aluno_id])
  mes_referencia = Date.current.strftime('%m/%Y')
  
  pagamento = Pagamento.find_by(
    aluno_id: aluno.alu_codigo,
    pag_descricao: "Mensalidade - #{mes_referencia}"
  )
  
  if pagamento
    if pagamento.quitado?
      render json: {
        quitado: true,
        valor_pago: pagamento.pag_valor_pago || pagamento.pag_valor,
        data_pagamento: pagamento.pag_data.strftime('%d/%m/%Y às %H:%M')
      }
    else
      render json: {
        quitado: false,
        pagamento_existente: true,
        valor_total: pagamento.pag_valor,
        valor_ja_pago: pagamento.pag_valor_pago || 0,
        valor_pendente: pagamento.valor_pendente
      }
    end
  else
    render json: {
      quitado: false,
      pagamento_existente: false,
      valor_total: Configuracao.valor_mensalidade
    }
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