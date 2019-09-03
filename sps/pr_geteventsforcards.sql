ALTER PROCEDURE dbo.pr_geteventsforcards (@city VARCHAR(100) = NULL,@state VARCHAR(100) = NULL, @api VARCHAR(100) = NULL, @date DATETIME =NULL, @filter VARCHAR(100) = NULL)

AS

-- DECLARE @city VARCHAR(100) = '',@state VARCHAR(100) = NULL, @date DATETIME ='', @api VARCHAR(100) = 'live_81da2ed8907d4b8b88fd505402c53c3c712cb4a62c274596ad4597b3787ff455' ,@filter VARCHAR(1000) = '' --'created'

IF @date = '1900-01-01 00:00:00.000'
    SET @date = NULL

SET NOCOUNT ON;

DECLARE @nowOrder DATETIME = DATEADD(day,15, GETDATE())
        ,@top INT = 500
        ,@id_partner UNIQUEIDENTIFIER
        ,@show_partner_info BIT

SELECT TOP 1 @id_partner=p.id,@show_partner_info=p.show_partner_info FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api

SELECT top (@top)
h.id_evento
,h.ds_evento
,h.codPeca
,h.ds_nome_teatro
,h.ds_municipio
,h.ds_estado
,h.sg_estado
,h.ds_regiao_geografica
,(CASE WHEN h.ds_municipio = @city COLLATE Latin1_general_CI_AI THEN 1
                WHEN h.ds_municipio != @city COLLATE Latin1_general_CI_AI
                     AND h.sg_estado = @state COLLATE Latin1_general_CI_AI THEN 2
                
                WHEN min(ap.dt_apresentacao)<=@nowOrder THEN 3
                ELSE 4 END) orderhelper
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
,(CASE WHEN (eei.maxAmount IS NULL OR eei.maxAmount = 0) AND (eei.minAmount IS NOT NULL AND eei.minAmount !=0) THEN FORMAT(CONVERT(DECIMAL(16,2),eei.minAmount)/100,(CASE WHEN ISNULL(eei.mmAmountIsPer,0) = 0 THEN 'C' ELSE 'g15' END), 'pt-br') ELSE FORMAT(CONVERT(DECIMAL(16,2),eei.minAmount)/100,(CASE WHEN ISNULL(eei.mmAmountIsPer,0) = 0 THEN 'C' ELSE 'g15' END), 'pt-br')+' a '+FORMAT(CONVERT(DECIMAL(16,2),eei.maxAmount)/100,(CASE WHEN ISNULL(eei.mmAmountIsPer,0) = 0 THEN 'C' ELSE 'g15' END), 'pt-br') END) valores
,FORMAT(CONVERT(DECIMAL(16,2),eei.minAmount)/100, (CASE WHEN ISNULL(eei.mmAmountIsPer,0) = 0 THEN 'C' ELSE 'g15' END), 'pt-br') minAmount
,FORMAT(CONVERT(DECIMAL(16,2),eei.maxAmount)/100,(CASE WHEN ISNULL(eei.mmAmountIsPer,0) = 0 THEN 'C' ELSE 'g15' END), 'pt-br') maxAmount
,ISNULL(eei.mmAmountIsPer,0) mmAmountIsPer
,@show_partner_info show_partner_info
,b.name_site [partner]
FROM home h
INNER JOIN CI_MIDDLEWAY..mw_evento e ON h.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento
INNER JOIN CI_MIDDLEWAY..partner_database pd ON e.id_base=pd.id_base AND pd.id_partner=@id_partner
INNER JOIN CI_MIDDLEWAY..mw_base b ON e.id_base=b.id_base
LEFT JOIN CI_MIDDLEWAY..genre g ON eei.id_genre=g.id
WHERE 
    DATEADD(minute, ((eei.minuteBefore)*-1), CONVERT(VARCHAR(10),ap.dt_apresentacao,121) + ' ' + REPLACE(ap.hr_apresentacao, 'h', ':') + ':00.000')>=GETDATE()
    AND (@date IS NULL OR ap.dt_apresentacao=@date)
    AND e.in_ativo=1
    AND ap.in_ativo=1
    --AND ds_municipio = @city COLLATE Latin1_general_CI_AI
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
,eei.mmAmountIsPer
,b.name_site
ORDER BY 
(CASE WHEN h.ds_municipio = @city COLLATE Latin1_general_CI_AI THEN 1
                WHEN h.ds_municipio != @city COLLATE Latin1_general_CI_AI
                     AND h.sg_estado = @state COLLATE Latin1_general_CI_AI THEN 2
                ELSE 4 END),
(CASE WHEN @filter IS NULL OR @filter = '' THEN min(ap.dt_apresentacao) END),
(CASE WHEN @filter = 'created' THEN eei.created END) DESC,
(CASE WHEN @filter = 'next' THEN min(ap.dt_apresentacao) END)