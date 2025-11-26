module Financeiro
  class EventoPagamentoService
    def initialize(evento_id, aluno_id, params)
      @evento = Evento.find(evento_id)
      @aluno = Aluno.find(aluno_id)
      @params = params
    end

    def registrar
      valor_pago = BigDecimal(@params[:valor_pago] || '0')
      pagamento = @evento.pagamentos.find_by(aluno_id: @aluno.alu_codigo)
      
      if pagamento
        pagamento.pag_valor_pago = (pagamento.pag_valor_pago || 0) + valor_pago
        atualizar_status(pagamento)
        pagamento.save
      else
        pagamento = criar_novo_pagamento(valor_pago)
      end
      
      pagamento
    end

    private

    def criar_novo_pagamento(valor_pago)
      pagamento = Pagamento.new(
        caixa_id: @params[:caixa_id],
        aluno_id: @aluno.alu_codigo,
        evento_id: @evento.EVE_CODIGO,
        pag_data: Time.current,
        pag_valor: @evento.EVE_VALOR || 0,
        pag_valor_pago: valor_pago,
        pag_descricao: "Pagamento - #{@evento.EVE_NOME}",
        pag_tipo: 'Entrada',
        pag_metodo: @params[:metodo] || 'Dinheiro'
      )
      
      atualizar_status(pagamento)
      pagamento.save
      pagamento
    end

    def atualizar_status(pagamento)
      if pagamento.pag_valor_pago >= pagamento.pag_valor
        pagamento.pag_status = 'Pago'
      else
        pagamento.pag_status = 'Pendente'
      end
    end
  end
end