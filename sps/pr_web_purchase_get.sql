ALTER PROCEDURE dbo.pr_web_purchase_get (@uniquename VARCHAR(100) = NULL
        ,@id_pedido_venda INT)

AS

-- DECLARE @uniquename VARCHAR(100) = 'viveringressos'
--         ,@id_pedido_venda INT = 7485


SELECT DISTINCT
    ipv.id_pedido_venda
    ,ipv.Indice
    ,ipv.tickettype
    ,ipv.vl_taxa_conveniencia
    ,ipv.vl_unitario
    ,ipv.CodVenda
    ,ipv.ds_setor
    ,ipv.ds_localizacao
    ,pv.cd_bin_cartao
    ,mp.ds_meio_pagamento
    ,pv.cd_numero_transacao
    ,pv.dt_pedido_venda
    ,CONVERT(VARCHAR(10), pv.dt_pedido_venda, 103) + ' ' + CONVERT(VARCHAR(10), pv.dt_pedido_venda, 108) created_at
    ,pv.id_cliente
    ,e.id_evento
    ,ap.id_apresentacao
    ,pv.in_situacao
    ,c.cd_cpf client_document
    ,c.ds_nome + ' ' + c.ds_sobrenome client_name
    ,c.cd_email_login
    ,c.ds_ddd_celular
    ,c.ds_celular
    ,e.ds_evento
    ,CONVERT(VARCHAR(10), ap.dt_apresentacao, 103) dt_apresentacao
    ,ap.hr_apresentacao
    ,pv.vl_total_pedido_venda
    ,eei.uri
    ,eei.cardimage
    ,bs.ds_nome_base_sql
    ,(SELECT COUNT(*) FROM CI_MIDDLEWAY..mw_item_pedido_venda sub WHERE sub.id_pedido_venda=ipv.id_pedido_venda) tickets_count
FROM CI_MIDDLEWAY..mw_item_pedido_venda ipv
INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON ipv.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..mw_cliente c ON pv.id_cliente=c.id_cliente
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..order_host oh ON pv.id_pedido_venda=oh.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..host h ON oh.id_host=h.id
INNER JOIN CI_MIDDLEWAY..mw_meio_pagamento mp ON pv.id_meio_pagamento=mp.id_meio_pagamento
INNER JOIN CI_MIDDLEWAY..mw_base bs ON e.id_base=bs.id_base
WHERE pv.id_pedido_venda=@id_pedido_venda
AND h.host=@uniquename