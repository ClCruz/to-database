ALTER PROCEDURE dbo.pr_site_place_events_get (@name VARCHAR(100), @api VARCHAR(1000))

AS

-- DECLARE @name VARCHAR(100) = 'teatro italia'
--         ,@api VARCHAR(1000) = 'live_b9ac22c87db04e5aa888c10023a785abb51709f099ae4123924dc02b6dd4814d'

SET NOCOUNT ON;

DECLARE @id_partner UNIQUEIDENTIFIER
        ,@show_partner_info BIT

SELECT TOP 1 @id_partner=p.id,@show_partner_info=p.show_partner_info FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api

IF OBJECT_ID('tempdb.dbo.#ids', 'U') IS NOT NULL
    DROP TABLE #ids; 


SELECT
le.id_local_evento
INTO #ids
FROM CI_MIDDLEWAY..mw_local_evento le
WHERE ds_local_evento COLLATE SQL_Latin1_General_CP1_CI_AI like '%'+@name+'%' COLLATE SQL_Latin1_General_CP1_CI_AI

SELECT--- top 10
h.id_evento
,h.ds_evento
,h.codPeca
,h.ds_nome_teatro
,h.ds_municipio
,h.ds_estado
,h.sg_estado
,h.ds_regiao_geografica
,h.cardimage
,h.cardbigimage
,h.imageoriginal
,h.uri
,h.dates
,h.[badges]
,h.[promotion]
,eei.id_genre
,CONVERT(VARCHAR(10), eei.created, 103) created
,g.name genreName
,(CASE WHEN eei.maxAmount IS NULL AND eei.minAmount IS NOT NULL THEN FORMAT(CONVERT(DECIMAL(16,2),eei.minAmount)/100,'C', 'pt-br') ELSE FORMAT(CONVERT(DECIMAL(16,2),eei.minAmount)/100,'C', 'pt-br')+' a '+FORMAT(CONVERT(DECIMAL(16,2),eei.maxAmount)/100,'C', 'pt-br') END) valores
,FORMAT(CONVERT(DECIMAL(16,2),eei.minAmount)/100,'C', 'pt-br') minAmount
,FORMAT(CONVERT(DECIMAL(16,2),eei.maxAmount)/100,'C', 'pt-br') maxAmount
,@show_partner_info show_partner_info
,b.name_site [partner]
FROM home h
INNER JOIN CI_MIDDLEWAY..mw_evento e ON h.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento
INNER JOIN CI_MIDDLEWAY..partner_database pd ON e.id_base=pd.id_base AND pd.id_partner=@id_partner
INNER JOIN CI_MIDDLEWAY..mw_base b ON e.id_base=b.id_base
INNER JOIN #ids ids ON e.id_local_evento=ids.id_local_evento
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
,h.ds_regiao_geografica
,h.cardimage
,h.cardbigimage
,h.imageoriginal
,h.uri
,h.dates
,h.badges
,h.promotion
,eei.id_genre
,eei.created
,g.name
,eei.minAmount
,eei.maxAmount
,b.name_site
ORDER BY 
min(ap.dt_apresentacao)