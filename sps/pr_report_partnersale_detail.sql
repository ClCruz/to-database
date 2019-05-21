ALTER PROCEDURE dbo.pr_report_partnersale_detail (@comission FLOAT
        ,@id_pedido_venda INT)

AS

-- DECLARE @comission FLOAT = 7.89
--         ,@id_pedido_venda INT = 1593

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#result', 'U') IS NOT NULL
    DROP TABLE #result; 

SELECT DISTINCT
        pv.id_pedido_venda
        ,CONVERT(VARCHAR(10),pv.dt_pedido_venda,103) dt_pedido_venda
        ,e.ds_evento
        ,e.id_evento
        ,eei.cardimage
        ,eei.uri
        ,CONVERT(VARCHAR(10),ap.dt_apresentacao,103) dt_apresentacao
        ,ap.hr_apresentacao
        ,pv.vl_total_pedido_venda
        ,REPLACE(mp.ds_meio_pagamento, 'Pagar.me ','') ds_meio_pagamento
        ,@comission comission
        ,CONVERT(DECIMAL(18,2),(ROUND(CONVERT(DECIMAL(18,4),pv.vl_total_pedido_venda)*(@comission)/100,2))) comission_amount
        ,FORMAT(CONVERT(DECIMAL(18,2),(ROUND(CONVERT(DECIMAL(18,4),pv.vl_total_pedido_venda)*(@comission)/100,2))), 'N', 'pt-br') comission_amount_formatted
        ,c.ds_nome + ' ' + c.ds_sobrenome [client_name]
        ,c.cd_cpf
        ,c.cd_email_login
        ,CONVERT(VARCHAR(10),c.dt_nascimento,103) dt_nascimento
        ,ab.ds_tipo_bilhete
        ,pv.nr_parcelas_pgto
        ,(CASE WHEN pv.nr_parcelas_pgto > 1 THEN 1 ELSE 0 END) isInstallment
        ,h.host
        ,b.ds_nome_base_sql
        ,ipv.Indice
        ,ipv.ds_localizacao
        ,ipv.vl_unitario
        ,ipv.vl_taxa_conveniencia
        ,ipv.CodVenda
        -- ,dbo.fnc_checkdomain(h.host,b.ds_nome_base_sql)
-- INTO #result
FROM CI_MIDDLEWAY..mw_pedido_venda pv
INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON pv.id_pedido_venda=ipv.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON ipv.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete ab ON ipv.id_apresentacao_bilhete=ab.id_apresentacao_bilhete AND ap.id_apresentacao=ab.id_apresentacao
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..mw_base b ON e.id_base=b.id_base
INNER JOIN CI_MIDDLEWAY..mw_meio_pagamento mp ON pv.id_meio_pagamento=mp.id_meio_pagamento
INNER JOIN CI_MIDDLEWAY..mw_cliente c ON pv.id_cliente=c.id_cliente
LEFT JOIN CI_MIDDLEWAY..order_host oh ON oh.id_pedido_venda=pv.id_pedido_venda AND oh.indice=ipv.Indice
LEFT JOIN CI_MIDDLEWAY..host h ON oh.id_host=h.id
WHERE pv.id_pedido_venda=@id_pedido_venda
