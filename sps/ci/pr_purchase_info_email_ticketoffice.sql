-- select * from CI_MIDDLEWAY..mw_base

-- pr_purchase_info_email_ticketoffice 'G6WDHOBFCO'


ALTER PROCEDURE dbo.pr_purchase_info_email_ticketoffice (@codVenda VARCHAR(10))

AS

-- DECLARE @codVenda VARCHAR(10) = 'G64FGOBFHO'

SET NOCOUNT ON;

DECLARE @id_base INT

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

IF OBJECT_ID('tempdb.dbo.#result', 'U') IS NOT NULL
    DROP TABLE #result; 

SELECT DISTINCT
    e.id_evento
    ,eei.cardimage
    ,eei.uri
    ,'' [buyer_name]
    ,'' buyer_email
    ,'' buyer_document
    ,'' voucher_id
    ,ls.CodVenda voucher_code
    ,'' voucher_link
    ,'' voucher_event_image
    ,'' voucher_event_link
    ,e.ds_evento voucher_event_name
    ,le.ds_local_evento voucher_local_name
    ,mu.ds_municipio voucher_event_city
    ,mue.sg_estado voucher_event_state
    ,tb.TipBilhete voucher_event_tickettype
    ,CONVERT(VARCHAR(10),ap.dt_apresentacao,103) voucher_event_date
    ,ap.hr_apresentacao voucher_event_hour
    ,0 voucher_event_amount
    ,0 voucher_event_service
    ,'' hostname
    ,'' hostfull
    ,ISNULL((SELECT TOP 1 1 FROM CI_MIDDLEWAY..email_ticket_print subetp WHERE subetp.codVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS AND subetp.seen = 0),0) printcodehas
    ,ISNULL((SELECT TOP 1 subetp.code FROM CI_MIDDLEWAY..email_ticket_print subetp WHERE subetp.codVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS AND subetp.seen = 0 ORDER BY subetp.created),'') printcode
INTO #result
FROM tabLugSala ls
INNER JOIN tabTipBilhete tb ON ls.CodTipBilhete=tb.CodTipBilhete
INNER JOIN tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao
INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete ab ON ap.id_apresentacao=ab.id_apresentacao AND ls.CodTipBilhete=ab.CodTipBilhete
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento AND e.id_base=@id_base
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..mw_local_evento le ON e.id_local_evento=le.id_local_evento
INNER JOIN CI_MIDDLEWAY..mw_municipio mu ON le.id_municipio=mu.id_municipio
INNER JOIN CI_MIDDLEWAY..mw_estado mue ON mu.id_estado=mue.id_estado
WHERE 
    ls.CodVenda=@codVenda COLLATE SQL_Latin1_General_CP1_CI_AS AND ls.StaCadeira='V'




SELECT
    r.id_evento
    ,r.cardimage
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
    ,FORMAT((SELECT SUM(voucher_event_amount) FROM #result),'C', 'pt-br') voucher_event_amount_total
    ,FORMAT((SELECT SUM(voucher_event_service) FROM #result),'C', 'pt-br') voucher_event_service_total
    ,FORMAT(((SELECT SUM(voucher_event_amount) FROM #result)+(SELECT SUM(voucher_event_service) FROM #result)),'C', 'pt-br') voucher_event_value_total
    ,printcode
    ,printcodehas
FROM #result r