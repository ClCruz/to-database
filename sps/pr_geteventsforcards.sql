-- exec sp_executesql N'EXEC pr_geteventsforcards @P1, @P2, @P3, @P4, @P5',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000)',N'Barueri',N'',N'live_dd310c796ff04199b5680a5cad098930c2ae8da63b974b43abb21d92ec5123b2',N'',N''

-- exec sp_executesql N'EXEC pr_geteventsforcards @P1, @P2, @P3, @P4, @P5',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000)',N'',N'',N'live_6bfa0de8c52f4dd0bbb53d5a61945bbddb2aaa5545644e61873f1d1cd78f6bae',N'',N''

-- EXEC pr_geteventsforcards @api='live_578abaf329f84119bb7c1e55dfdc7e0f4f20e693cd2c4bc7a5bc0a0965fae322'
-- exec sp_executesql N'EXEC pr_geteventsforcards @P1, @P2, @P3, @P4',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000)',N'',N'',N'live_279e0f576f1547faa1ac5600d7802778f3754aa3f6d44f9aabbdbb709b2ed442',N'created'

ALTER PROCEDURE dbo.pr_geteventsforcards (@city VARCHAR(100) = NULL,@state VARCHAR(100) = NULL, @api VARCHAR(100) = NULL, @date DATETIME =NULL, @filter VARCHAR(100) = NULL)

AS


-- DECLARE @city VARCHAR(100) = '',@state VARCHAR(100) = NULL, @date DATETIME ='', @api VARCHAR(100) = 'live_dd310c796ff04199b5680a5cad098930c2ae8da63b974b43abb21d92ec5123b2' ,@filter VARCHAR(1000) = '' --'created'

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
LEFT JOIN CI_MIDDLEWAY..genre g ON eei.id_genre=g.id
WHERE 
    DATEADD(minute, ((eei.minuteBefore)*-1), CONVERT(VARCHAR(10),ap.dt_apresentacao,121) + ' ' + REPLACE(ap.hr_apresentacao, 'h', ':') + ':00.000')>=GETDATE()
    AND (@date IS NULL OR ap.dt_apresentacao=@date)
    AND e.in_ativo=1
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
,b.name_site
ORDER BY 
(CASE WHEN h.ds_municipio = @city COLLATE Latin1_general_CI_AI THEN 1
                WHEN h.ds_municipio != @city COLLATE Latin1_general_CI_AI
                     AND h.sg_estado = @state COLLATE Latin1_general_CI_AI THEN 2
                ELSE 4 END),
(CASE WHEN @filter IS NULL OR @filter = '' THEN min(ap.dt_apresentacao) END),
(CASE WHEN @filter = 'created' THEN eei.created END) DESC,
(CASE WHEN @filter = 'next' THEN min(ap.dt_apresentacao) END)