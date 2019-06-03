
ALTER PROCEDURE dbo.pr_api_presentation_list (@key VARCHAR(1000), @date DATETIME = NULL)

AS

-- DECLARE @key VARCHAR(1000) = 'qp_625b2ce3dcc14c1bba8058a436c9a36ac3e7dfcabcfd4a7f8fc391c8488c16f4'

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#events', 'U') IS NOT NULL
    DROP TABLE #events; 

IF OBJECT_ID('tempdb.dbo.#presentation', 'U') IS NOT NULL
    DROP TABLE #presentation; 

SELECT
h.id_evento [id]
,e.id_base base
,h.ds_evento [name]
,h.codPeca id_old
,h.ds_nome_teatro [place]
,h.ds_municipio [city]
,h.ds_estado [state]
,h.sg_estado [state_acronym]
,h.cardimage [image_card]
,h.cardbigimage [image_big]
,h.uri
,h.dates
,eei.id_genre
,CONVERT(VARCHAR(10), eei.created, 103) created
,g.name genreName 
,(CASE WHEN eei.maxAmount IS NULL AND eei.minAmount IS NOT NULL THEN FORMAT(CONVERT(DECIMAL(16,2),eei.minAmount)/100,'C', 'pt-br') ELSE FORMAT(CONVERT(DECIMAL(16,2),eei.minAmount)/100,'C', 'pt-br')+' a '+FORMAT(CONVERT(DECIMAL(16,2),eei.maxAmount)/100,'C', 'pt-br') END) amounts
,FORMAT(CONVERT(DECIMAL(16,2),eei.minAmount)/100,'C', 'pt-br') minAmount
,FORMAT(CONVERT(DECIMAL(16,2),eei.maxAmount)/100,'C', 'pt-br') maxAmount
INTO #events
FROM home h
INNER JOIN CI_MIDDLEWAY..mw_evento e ON h.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento
INNER JOIN CI_MIDDLEWAY..quota_partner_reservation qpr ON ap.id_apresentacao=qpr.id_apresentacao
INNER JOIN CI_MIDDLEWAY..quota_partner qp ON qpr.id_quotapartner=qp.id AND qp.[key]=@key
LEFT JOIN CI_MIDDLEWAY..genre g ON eei.id_genre=g.id
WHERE 
    DATEADD(minute, ((eei.minuteBefore)*-1), CONVERT(VARCHAR(10),ap.dt_apresentacao,121) + ' ' + REPLACE(ap.hr_apresentacao, 'h', ':') + ':00.000')>=GETDATE()
    AND e.in_ativo=1
GROUP BY 
h.id_evento
,h.ds_evento
,h.codPeca
,h.ds_nome_teatro
,h.ds_municipio
,h.ds_estado
,h.sg_estado
,h.cardimage
,h.cardbigimage
,h.uri
,h.dates
,eei.id_genre
,eei.created
,g.name
,eei.minAmount
,eei.maxAmount
,e.id_base

SELECT 
ev.[id] id_event
,ap.id_apresentacao id_presentantion
,CONVERT(VARCHAR(10), ap.dt_apresentacao, 103) dt_presentation
,ap.hr_apresentacao hour_presentation
FROM CI_MIDDLEWAY..mw_apresentacao ap
INNER JOIN #events ev ON ap.id_evento=ev.id
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento AND e.id_base=ev.base
INNER JOIN CI_MIDDLEWAY..quota_partner_reservation qpr ON ap.id_apresentacao=qpr.id_apresentacao
INNER JOIN CI_MIDDLEWAY..quota_partner qp ON qpr.id_quotapartner=qp.id AND qp.[key]=@key
GROUP BY
ev.[id]
,ap.id_apresentacao
,CONVERT(VARCHAR(10), ap.dt_apresentacao, 103)
,ap.hr_apresentacao 