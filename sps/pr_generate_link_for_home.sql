-- pr_generate_link_for_home 'bringressos'

ALTER PROCEDURE dbo.pr_generate_link_for_home (@uniquename VARCHAR(100))

AS
-- DECLARE @uniquename VARCHAR(100) = 'bringressos'

DECLARE @homeChange VARCHAR(100) = 'always'
        ,@eventChange VARCHAR(100) = 'daily'
        ,@other VARCHAR(100) = 'never'
        ,@domain VARCHAR(1000) = 'DOMAIN'

SET NOCOUNT ON;

DECLARE @id_partner UNIQUEIDENTIFIER
        ,@domainPartner VARCHAR(1000) = NULL

SELECT TOP 1 @id_partner=p.id
            ,@domainPartner=p.domain FROM CI_MIDDLEWAY..[partner] p WHERE p.uniquename=@uniquename


IF @domainPartner IS NULL
    SET @domainPartner='https://www.tixs.me';

SET @domain = @domainPartner


IF OBJECT_ID('tempdb.dbo.#helper', 'U') IS NOT NULL
    DROP TABLE #helper; 

CREATE TABLE #helper ([uri] varchar(max), created varchar(10), [name] varchar(max), [desc] varchar(max));

INSERT INTO #helper ([uri], created,[name], [desc])
SELECT uri,created, t.ds_evento, t.[description] FROM (
SELECT DISTINCT e.id_evento, e.ds_evento, eei.[description], eei.uri, CONVERT(VARCHAR(10),eei.created,120) created
,(CASE WHEN DATEADD(minute, ((eei.minuteBefore)*-1), CONVERT(VARCHAR(10),ap.dt_apresentacao,121) + ' ' + REPLACE(ap.hr_apresentacao, 'h', ':') + ':00.000')>=GETDATE() THEN 1 ELSE 0 END) hasAp
,(CASE WHEN ap.dt_apresentacao <= DATEADD(year, -1, GETDATE()) THEN 1 ELSE 0 END) morethanoneyear
,(CASE WHEN ap.dt_apresentacao <= DATEADD(year, -2, GETDATE()) THEN 1 ELSE 0 END) morethantwoyear
FROM CI_MIDDLEWAY..mw_evento e
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..partner_database pd ON e.id_base=pd.id_base AND pd.id_partner=@id_partner
LEFT JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento) as t WHERE t.morethantwoyear=0
ORDER BY t.morethanoneyear, t.uri, t.ds_evento



SELECT '<a href="'+CONCAT('https://',@domain)+'/">'+@domain+'</a>' as result
UNION ALL
SELECT '<a href="'+CONCAT('https://',@domain,h.uri)+'">'+h.[name]+' - '+ h.[desc] +'</a>' as result FROM #helper h
UNION ALL
SELECT '</urlset>' as result