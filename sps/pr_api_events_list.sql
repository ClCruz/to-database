
ALTER PROCEDURE dbo.pr_api_events_list (@key VARCHAR(1000), @date DATETIME = NULL)

AS

-- DECLARE @key VARCHAR(1000) = 'qp_ab8665e1345545bcb8c53afaaf83d257cf574ed6b0724526aa9f1d156d730fd3'
--         ,@date DATETIME = NULL
--         -- ,@date DATETIME = '2019-05-31 13:49:19.693'

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#events', 'U') IS NOT NULL
    DROP TABLE #events; 

IF OBJECT_ID('tempdb.dbo.#presentation', 'U') IS NOT NULL
    DROP TABLE #presentation; 

SELECT
h.id_evento [id]
,e.id_base base
,(CASE WHEN b.ds_nome_base_sql = 'ci_localhost' THEN 'localhost' ELSE b.ds_nome_base_sql END) baseName
,h.ds_evento [name]
,h.codPeca code
,h.ds_nome_teatro [place]
,h.ds_municipio [city]
,h.ds_estado [state]
,h.sg_estado [state_acronym]
,h.cardimage [image_card]
,h.cardbigimage [image_big]
,h.uri
,h.dates
,eei.id_genre
-- ,CONVERT(VARCHAR(10), eei.created, 103) created
,eei.created
,g.name genreName 
,(CASE WHEN eei.maxAmount IS NULL AND eei.minAmount IS NOT NULL THEN FORMAT(CONVERT(DECIMAL(16,2),eei.minAmount)/100,'C', 'pt-br') ELSE FORMAT(CONVERT(DECIMAL(16,2),eei.minAmount)/100,'C', 'pt-br')+' a '+FORMAT(CONVERT(DECIMAL(16,2),eei.maxAmount)/100,'C', 'pt-br') END) amounts
,FORMAT(CONVERT(DECIMAL(16,2),eei.minAmount)/100,'C', 'pt-br') minAmount
,FORMAT(CONVERT(DECIMAL(16,2),eei.maxAmount)/100,'C', 'pt-br') maxAmount
,(CASE WHEN eei.changed IS NULL THEN eei.created ELSE eei.changed END) changed
-- INTO #events
FROM home h
INNER JOIN CI_MIDDLEWAY..mw_evento e ON h.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento
INNER JOIN CI_MIDDLEWAY..quota_partner_reservation qpr ON ap.id_apresentacao=qpr.id_apresentacao
INNER JOIN CI_MIDDLEWAY..quota_partner qp ON qpr.id_quotapartner=qp.id AND qp.[key]=@key
INNER JOIN CI_MIDDLEWAY..mw_base b ON e.id_base=b.id_base
LEFT JOIN CI_MIDDLEWAY..genre g ON eei.id_genre=g.id
WHERE 
    DATEADD(minute, ((eei.minuteBefore)*-1), CONVERT(VARCHAR(10),ap.dt_apresentacao,121) + ' ' + REPLACE(ap.hr_apresentacao, 'h', ':') + ':00.000')>=GETDATE()
    AND e.in_ativo=1
    AND (@date IS NULL OR (eei.changed IS NULL OR eei.changed>=@date))
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
,b.ds_nome_base_sql
,eei.changed