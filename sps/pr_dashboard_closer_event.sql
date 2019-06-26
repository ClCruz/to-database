ALTER PROCEDURE dbo.pr_dashboard_closer_event (@id_user UNIQUEIDENTIFIER)


AS

-- DECLARE @id_user UNIQUEIDENTIFIER = 'F2177E5E-F727-4906-948D-4EEA9B9BBD0E'

SELECT TOP 1
h.id_evento
,h.ds_evento
,e.id_base
,CONVERT(VARCHAR(10),MIN(ap.dt_apresentacao),103) [date]
,MIN(ap.hr_apresentacao) [hour]
FROM home h
INNER JOIN CI_MIDDLEWAY..mw_evento e ON h.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento
INNER JOIN CI_MIDDLEWAY..mw_base b ON e.id_base=b.id_base
INNER JOIN CI_MIDDLEWAY..to_admin_user_base taub ON b.id_base=taub.id_base AND taub.active=1 AND taub.id_to_admin_user=@id_user
LEFT JOIN CI_MIDDLEWAY..genre g ON eei.id_genre=g.id
WHERE 
    DATEADD(minute, ((eei.minuteBefore)*-1), CONVERT(VARCHAR(10),ap.dt_apresentacao,121) + ' ' + REPLACE(ap.hr_apresentacao, 'h', ':') + ':00.000')>=GETDATE()
    AND e.in_ativo=1
    AND ap.in_ativo=1
GROUP BY 
h.id_evento
,h.ds_evento
,e.id_base
ORDER BY min(ap.dt_apresentacao), min(ap.hr_apresentacao)