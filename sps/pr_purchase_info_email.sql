-- pr_purchase_info_email 9

ALTER PROCEDURE dbo.pr_purchase_info_email (@id_pedido_venda INT)

AS

SELECT
    e.id_evento
    ,eei.cardimage
    ,eei.uri
    ,c.ds_nome + ' ' + c.ds_sobrenome [buyer_name]
    ,c.cd_email_login buyer_email
    ,c.cd_cpf buyer_document
    ,pv.id_pedido_venda voucher_id
    ,ipv.CodVenda voucher_code
    ,'' voucher_link
    ,'' voucher_event_image
    ,'' voucher_event_link
    ,e.ds_evento voucher_event_name
    ,mu.ds_municipio voucher_event_city
    ,mue.sg_estado voucher_event_state
    ,ipv.tickettype voucher_event_tickettype
    ,CONVERT(VARCHAR(10),ap.dt_apresentacao,103) voucher_event_date
    ,ap.hr_apresentacao voucher_event_hour
    ,ipv.vl_unitario voucher_event_amount
    ,ipv.vl_taxa_conveniencia voucher_event_service
FROM CI_MIDDLEWAY..mw_pedido_venda pv
INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON pv.id_pedido_venda=ipv.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete ab ON ipv.id_apresentacao_bilhete=ab.id_apresentacao_bilhete
INNER JOIN CI_MIDDLEWAY..mw_cliente c ON pv.id_cliente=c.id_cliente
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON ipv.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..mw_local_evento le ON e.id_local_evento=le.id_local_evento
INNER JOIN CI_MIDDLEWAY..mw_municipio mu ON le.id_municipio=mu.id_municipio
INNER JOIN CI_MIDDLEWAY..mw_estado mue ON mu.id_estado=mue.id_estado
WHERE 
    pv.id_pedido_venda=@id_pedido_venda