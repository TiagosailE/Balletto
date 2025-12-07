module Financeiro
  class MensalidadeService
    def initialize(aluno_id, params)
      @aluno = Aluno.find(aluno_id)
      @params = params
      @configuracao = Configuracao.instance
    end

    def info_mensalidade
      mes_atual = Date.current.month
      ano_atual = Date.current.year

      pagamento_existente = Pagamento.find_by(
        aluno_id: @aluno.alu_codigo,
        pag_descricao: "Mensalidade - #{mes_atual.to_s.rjust(2, '0')}/#{ano_atual}"
      )

      dia_vencimento = @configuracao.dia_vencimento_mensalidade
      data_vencimento = Date.new(ano_atual, mes_atual, dia_vencimento) rescue Date.current
      
      if pagamento_existente
        {
          valor_total: pagamento_existente.pag_valor,
          valor_pago: pagamento_existente.pag_valor_pago || 0,
          valor_pendente: pagamento_existente.valor_pendente,
          status: pagamento_existente.pag_status,
          atrasado: pagamento_existente.atrasado?,
          dias_atraso: pagamento_existente.dias_atraso,
          data_vencimento: data_vencimento.strftime('%d/%m/%Y'),
          pagamento_id: pagamento_existente.pag_codigo,
          quitado: pagamento_existente.quitado?
        }
      else
        {
          valor_total: @configuracao.con_valor_mensalidade,
          valor_pago: 0,
          valor_pendente: @configuracao.con_valor_mensalidade,
          status: 'Pendente',
          atrasado: Date.current > data_vencimento,
          dias_atraso: Date.current > data_vencimento ? (Date.current - data_vencimento).to_i : 0,
          data_vencimento: data_vencimento.strftime('%d/%m/%Y'),
          pagamento_id: nil,
          quitado: false
        }
      end
    end

    def registrar
      mes_atual = Date.current.month
      ano_atual = Date.current.year
      descricao = "Mensalidade - #{mes_atual.to_s.rjust(2, '0')}/#{ano_atual}"

      pagamento = Pagamento.find_or_initialize_by(
        aluno_id: @aluno.alu_codigo,
        pag_descricao: descricao
      )

      valor_total = @params[:valor_total].to_f
      valor_pago_agora = @params[:valor_pago].to_f
      valor_pago_anterior = pagamento.pag_valor_pago || 0

      novo_valor_pago = valor_pago_anterior + valor_pago_agora

      pagamento.assign_attributes(
        pag_data: Time.current,
        pag_valor: valor_total,
        pag_valor_pago: novo_valor_pago,
        pag_tipo: 'Entrada',
        pag_metodo: @params[:metodo],
        caixa_id: @params[:caixa_id]
      )

      pagamento.save

      if pagamento.persisted? && valor_pago_agora > 0
        caixa = Caixa.find(@params[:caixa_id])
        caixa.update(cai_saldo_inicial: caixa.cai_saldo_inicial + valor_pago_agora)
      end

      pagamento
    end

    def editar_pagamento(pagamento_id)
      pagamento = Pagamento.find(pagamento_id)

      if pagamento.caixa_id && pagamento.pag_valor_pago
        caixa_anterior = Caixa.find(pagamento.caixa_id)
        caixa_anterior.update(
          cai_saldo_inicial: caixa_anterior.cai_saldo_inicial - pagamento.pag_valor_pago
        )
      end

      novo_valor_pago = @params[:valor_pago].to_f
      novo_valor_total = @params[:valor_total].to_f

      pagamento.update(
        pag_valor: novo_valor_total,
        pag_valor_pago: novo_valor_pago,
        pag_metodo: @params[:metodo],
        caixa_id: @params[:caixa_id]
      )

      if pagamento.persisted? && @params[:caixa_id]
        caixa_novo = Caixa.find(@params[:caixa_id])
        caixa_novo.update(
          cai_saldo_inicial: caixa_novo.cai_saldo_inicial + novo_valor_pago
        )
      end

      pagamento
    end
  end
end