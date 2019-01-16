ALTER PROCEDURE dbo.pr_geteventsforbanner (@api VARCHAR(100) = NULL)

AS

--DECLARE @city VARCHAR(100) = NULL,@state VARCHAR(100) = NULL, @api VARCHAR(100) = 'live_keykeykey'

SET NOCOUNT ON;

DECLARE @nowOrder DATETIME = DATEADD(day,15, GETDATE())
        ,@top INT = 10
        ,@id_partner UNIQUEIDENTIFIER

SELECT TOP 1 @id_partner=p.id FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api

SELECT top (@top)
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
,g.name genreName
,eei.bannerDescription
FROM home h
INNER JOIN CI_MIDDLEWAY..mw_evento e ON h.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento
INNER JOIN CI_MIDDLEWAY..partner_database pd ON e.id_base=pd.id_base AND pd.id_partner=@id_partner
LEFT JOIN CI_MIDDLEWAY..genre g ON eei.id_genre=g.id
WHERE 
    eei.showInBanner = 1
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
,g.name
,eei.bannerDescription

ORDER BY min(ap.dt_apresentacao)
