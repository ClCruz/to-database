-- pr_purchase_info_email 133


ALTER PROCEDURE dbo.pr_purchase_info_email_api (@id_pedido_venda INT)

AS

-- DECLARE @id_pedido_venda INT = 1736

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#result', 'U') IS NOT NULL
    DROP TABLE #result; 

SELECT DISTINCT
    e.id_evento
    ,ipv.Indice
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
    ,le.ds_local_evento voucher_local_name
    ,mu.ds_municipio voucher_event_city
    ,mue.sg_estado voucher_event_state
    ,ipv.tickettype voucher_event_tickettype
    ,CONVERT(VARCHAR(10),ap.dt_apresentacao,103) voucher_event_date
    ,ap.hr_apresentacao voucher_event_hour
    ,ipv.vl_unitario voucher_event_amount
    ,ipv.vl_taxa_conveniencia voucher_event_service
    ,h.name hostname
    ,h.host hostfull
    ,pv.vl_total_pedido_venda
    ,pv.vl_total_taxa_conveniencia
    ,ISNULL((SELECT TOP 1 1 FROM CI_MIDDLEWAY..email_ticket_print subetp WHERE subetp.codVenda=ipv.CodVenda AND subetp.seen = 0),0) printcodehas
    ,ISNULL((SELECT TOP 1 subetp.code FROM CI_MIDDLEWAY..email_ticket_print subetp WHERE subetp.codVenda=ipv.CodVenda AND subetp.seen = 0 ORDER BY subetp.created),'') printcode
    ,'web' [type]
    ,pv.nr_parcelas_pgto
    ,(CASE WHEN e.in_entrega_ingresso = 1 THEN 'physical-ticket' ELSE 'e-ticket' END) delivery_method
    ,b.name_site
INTO #result
FROM CI_MIDDLEWAY..mw_pedido_venda pv
INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON pv.id_pedido_venda=ipv.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete ab ON ipv.id_apresentacao_bilhete=ab.id_apresentacao_bilhete AND ab.IN_ATIVO = 1
INNER JOIN CI_MIDDLEWAY..order_host oh ON pv.id_pedido_venda=oh.id_pedido_venda AND ipv.Indice=oh.indice
INNER JOIN CI_MIDDLEWAY..host h ON oh.id_host=h.id
INNER JOIN CI_MIDDLEWAY..mw_cliente c ON pv.id_cliente=c.id_cliente
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON ipv.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_base b ON e.id_base=b.id_base
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..mw_local_evento le ON e.id_local_evento=le.id_local_evento
INNER JOIN CI_MIDDLEWAY..mw_municipio mu ON le.id_municipio=mu.id_municipio
INNER JOIN CI_MIDDLEWAY..mw_estado mue ON mu.id_estado=mue.id_estado
WHERE 
    pv.id_pedido_venda=@id_pedido_venda


SELECT
    r.id_evento
    ,r.cardimage
    ,r.Indice
    ,r.uri
    ,r.[buyer_name]
    ,r.buyer_email
    ,r.buyer_document
    ,r.voucher_id
    ,r.voucher_code
    ,r.voucher_link
    ,r.voucher_event_image
    ,r.voucher_event_link
    ,r.voucher_event_name
    ,r.voucher_local_name
    ,r.voucher_event_city
    ,r.voucher_event_state
    ,r.voucher_event_tickettype
    ,r.voucher_event_date
    ,r.voucher_event_hour
    ,FORMAT(r.voucher_event_amount,'C', 'pt-br') voucher_event_amount
    ,FORMAT(r.voucher_event_service,'C', 'pt-br') voucher_event_service
    ,r.hostname
    ,r.hostfull
    -- ,FORMAT((SELECT SUM(voucher_event_amount) FROM #result),'C', 'pt-br') voucher_event_amount_total
    -- ,FORMAT((SELECT SUM(voucher_event_service) FROM #result),'C', 'pt-br') voucher_event_service_total
    -- ,FORMAT(((SELECT SUM(voucher_event_amount) FROM #result)+(SELECT SUM(voucher_event_service) FROM #result)),'C', 'pt-br') voucher_event_value_total
    ,FORMAT(r.vl_total_pedido_venda-r.vl_total_taxa_conveniencia,'C', 'pt-br') voucher_event_amount_total
    ,FORMAT(r.vl_total_taxa_conveniencia,'C', 'pt-br') voucher_event_service_total
    ,FORMAT(r.vl_total_pedido_venda,'C', 'pt-br') voucher_event_value_total
    ,r.printcode
    ,r.printcodehas
    ,r.[type]
    ,r.nr_parcelas_pgto
    ,delivery_method
    ,r.name_site
FROM #result r