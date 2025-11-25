class FinanceiroController < ApplicationController
  before_action :authenticate_user!
  include ActionView::Helpers::NumberHelper

  def index
  @configuracao = Configuracao.instance
  @valor_mensalidade = @configuracao.con_valor_mensalidade
  @dia_vencimento = @configuracao.dia_vencimento_mensalidade
  
  @alunos = Aluno.order(:alu_nome)
  @caixas = Caixa.order(:cai_nome)
  @eventos = Evento.where('"EVE_DATA" >= ?', Date.current).order('"EVE_DATA" ASC')
  
  Pagamento.atualizar_status_mensalidades
  
  @pagamentos = Pagamento.includes(:caixa, :aluno, :evento)
                         .where('pag_data >= ?', 1.month.ago)
                         .order(pag_data: :desc)
  
  calcular_totais

  respond_to do |format|
    format.html
    format.pdf { render_extrato_pdf }
  end
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
    evento = Evento.includes(participantes_confirmados: :foto_attachment).find(params[:evento_id])
    caixas = Caixa.order(:cai_nome)
    
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
      evento: { id: evento.EVE_CODIGO, nome: evento.EVE_NOME, valor: evento.EVE_VALOR || 0 },
      participantes: participantes,
      caixas: caixas.map { |c| { id: c.cai_codigo, nome: c.cai_nome } }
    }
  rescue => e
    render json: { success: false, error: "Erro ao carregar participantes: #{e.message}" }, status: :internal_server_error
  end

  def registrar_pagamento_evento
    service = Financeiro::EventoPagamentoService.new(params[:evento_id], params[:aluno_id], params)
    pagamento = service.registrar
    
    if pagamento.persisted?
      render json: { 
        success: true, 
        message: pagamento.quitado? ? 'Pagamento quitado!' : "Pagamento registrado! Faltam #{number_to_currency(pagamento.valor_pendente)}",
        pagamento_id: pagamento.pag_codigo,
        valor_pendente: pagamento.valor_pendente,
        quitado: pagamento.quitado?
      }
    else
      render json: { success: false, errors: pagamento.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def atualizar_valor_mensalidade
    configuracao = Configuracao.instance
    
    if configuracao.update(
      con_valor_mensalidade: params[:valor].to_f,
      dia_vencimento_mensalidade: params[:dia_vencimento].to_i
    )
      render json: { 
        success: true, 
        mensagem: 'Configuração atualizada com sucesso!',
        valor: configuracao.con_valor_mensalidade,
        dia_vencimento: configuracao.dia_vencimento_mensalidade
      }
    else
      render json: { success: false, mensagem: configuracao.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def registrar_pagamento_mensalidade
    service = Financeiro::MensalidadeService.new(params[:aluno_id], params)
    pagamento = service.registrar
    
    if pagamento.persisted?
      render json: { 
        success: true, 
        mensagem: pagamento.quitado? ? 'Mensalidade quitada!' : "Pagamento registrado! Faltam #{number_to_currency(pagamento.valor_pendente)}",
        status: pagamento.pag_status,
        atrasado: pagamento.atrasado?,
        dias_atraso: pagamento.dias_atraso
      }
    else
      render json: { success: false, mensagem: pagamento.errors.full_messages.join(', ') }, status: :unprocessable_entity
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
      render json: { success: true, message: 'Despesa registrada com sucesso!' }
    else
      render json: { success: false, errors: pagamento.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def info_mensalidade_aluno
    service = Financeiro::MensalidadeService.new(params[:aluno_id], {})
    render json: service.info_mensalidade
  end
  
  private
  
  def calcular_totais
    @total_entradas = @pagamentos.where(pag_tipo: 'Entrada').sum(:pag_valor)
    @total_saidas = @pagamentos.where(pag_tipo: 'Saída').sum(:pag_valor)
    @saldo_total = Caixa.sum("cai_saldo_inicial") + @total_entradas - @total_saidas
  end
  
  def render_extrato_pdf
    pdf = Prawn::Document.new(page_size: 'A4', margin: 40)
    
    pdf.font 'Helvetica', size: 20, style: :bold
    pdf.text 'Extrato Financeiro', align: :center
    pdf.move_down 5
    
    pdf.font 'Helvetica', size: 10
    data_inicio = 1.month.ago.beginning_of_day
    pdf.text "Período: #{data_inicio.strftime('%d/%m/%Y')} a #{Date.current.strftime('%d/%m/%Y')}", align: :center
    pdf.text "Gerado em: #{Time.current.strftime('%d/%m/%Y às %H:%M')}", align: :center
    pdf.move_down 20

    totais_data = [
      ['ENTRADAS', 'SAÍDAS', 'SALDO'],
      [number_to_currency(@total_entradas), number_to_currency(@total_saidas), number_to_currency(@saldo_total)]
    ]
    
    pdf.table(totais_data, width: pdf.bounds.width, cell_style: { align: :center, padding: 8 }) do
      row(0).background_color = 'E5E5E5'
      row(0).font_style = :bold
      row(1).background_color = 'F9F9F9'
    end
    
    pdf.move_down 20
    pdf.font 'Helvetica', size: 12, style: :bold
    pdf.text 'Lançamentos'
    pdf.move_down 10

    if @pagamentos.empty?
      pdf.font 'Helvetica', size: 10
      pdf.text 'Nenhum lançamento encontrado no período.', align: :center
    else
      transacoes_data = [['Data', 'Descrição', 'Tipo', 'Valor', 'Status']]
      
      @pagamentos.each do |p|
        tipo = p.pag_tipo == 'Entrada' ? 'Entrada' : 'Saída'
        valor_formatado = "#{p.pag_tipo == 'Entrada' ? '+' : '-'} #{number_to_currency(p.pag_valor)}"
        
        transacoes_data << [
          p.pag_data.strftime('%d/%m/%Y'),
          p.pag_descricao.presence || 'Lançamento',
          tipo,
          valor_formatado,
          p.pag_status
        ]
      end

      pdf.font 'Helvetica', size: 8
      pdf.table(transacoes_data, width: pdf.bounds.width, cell_style: { padding: 5 }) do
        row(0).background_color = 'C5A300'
        row(0).text_color = 'FFFFFF'
        row(0).font_style = :bold
        column(3).align = :right
        cells.border_width = 0.5
        cells.border_color = 'CCCCCC'
      end
    end
    
    pdf.number_pages "Página <page> de <total>", at: [pdf.bounds.right - 150, 0], width: 150, align: :right, size: 8

    send_data pdf.render,
              filename: "extrato_financeiro_#{Date.current.strftime('%Y%m%d')}.pdf",
              type: 'application/pdf',
              disposition: 'attachment'
  end
end
