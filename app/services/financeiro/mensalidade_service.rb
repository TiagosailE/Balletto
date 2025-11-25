module Financeiro
  class MensalidadeService
    def initialize(aluno_id, params)
      @aluno = Aluno.find(aluno_id)
      @params = params
    end

    def registrar
      valor_total = @params[:valor_total] || Configuracao.instance.con_valor_mensalidade
      valor_pago = BigDecimal(@params[:valor_pago] || '0')
      mes_referencia = @params[:mes_referencia] || Date.current.strftime('%m/%Y')

      pagamento = buscar_ou_criar_pagamento(mes_referencia, valor_total, valor_pago)
      pagamento
    end

    def info_mensalidade
      mes_referencia = Date.current.strftime('%m/%Y')
      pagamento = Pagamento.find_by(
        aluno_id: @aluno.alu_codigo,
        pag_descricao: "Mensalidade - #{mes_referencia}"
      )

      if pagamento
        info_pagamento_existente(pagamento)
      else
        info_sem_pagamento
      end
    end

    private

    def buscar_ou_criar_pagamento(mes_referencia, valor_total, valor_pago)
      pagamento = Pagamento.find_by(
        aluno_id: @aluno.alu_codigo,
        pag_descricao: "Mensalidade - #{mes_referencia}"
      )
      
      if pagamento
        pagamento.pag_valor_pago = (pagamento.pag_valor_pago || 0) + valor_pago
        pagamento.save
        pagamento
      else
        criar_nova_mensalidade(mes_referencia, valor_total, valor_pago)
      end
    end

    def criar_nova_mensalidade(mes_referencia, valor_total, valor_pago)
      configuracao = Configuracao.instance
      dia_vencimento = configuracao.dia_vencimento_mensalidade
      data_vencimento = Date.new(Date.current.year, Date.current.month, dia_vencimento)

      Pagamento.create(
        caixa_id: @params[:caixa_id],
        aluno_id: @aluno.alu_codigo,
        pag_data: data_vencimento,
        pag_valor: valor_total,
        pag_valor_pago: valor_pago,
        pag_descricao: "Mensalidade - #{mes_referencia}",
        pag_tipo: 'Entrada',
        pag_metodo: @params[:metodo] || 'Dinheiro'
      )
    end

    def info_pagamento_existente(pagamento)
      if pagamento.quitado?
        {
          quitado: true,
          valor_total: pagamento.pag_valor,
          valor_pago: pagamento.pag_valor_pago || pagamento.pag_valor,
          valor_pendente: 0,
          status: pagamento.pag_status,
          data_vencimento: pagamento.data_vencimento&.strftime('%d/%m/%Y'),
          dias_atraso: pagamento.dias_atraso,
          atrasado: pagamento.atrasado?
        }
      else
        {
          quitado: false,
          valor_total: pagamento.pag_valor,
          valor_pago: pagamento.pag_valor_pago || 0,
          valor_pendente: pagamento.valor_pendente,
          status: pagamento.pag_status,
          data_vencimento: pagamento.data_vencimento&.strftime('%d/%m/%Y'),
          dias_atraso: pagamento.dias_atraso,
          atrasado: pagamento.atrasado?
        }
      end
    end

    def info_sem_pagamento
      configuracao = Configuracao.instance
      dia_vencimento = configuracao.dia_vencimento_mensalidade
      data_vencimento = Date.new(Date.current.year, Date.current.month, dia_vencimento)
      
      {
        quitado: false,
        valor_total: configuracao.con_valor_mensalidade,
        valor_pago: 0,
        valor_pendente: configuracao.con_valor_mensalidade,
        status: 'Pendente',
        data_vencimento: data_vencimento.strftime('%d/%m/%Y'),
        dias_atraso: 0,
        atrasado: false
      }
    end
  end
end
