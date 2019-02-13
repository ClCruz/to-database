ALTER PROCEDURE dbo.pr_events_bypair (@code VARCHAR(10))

AS
-- DECLARE @code VARCHAR(10) = '12345'

SELECT DISTINCT
e.id_evento
,e.CodPeca
,e.id_base
,e.ds_evento
,eei.cardimage
,eei.uri
FROM CI_MIDDLEWAY..mw_evento e
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento
INNER JOIN CI_MIDDLEWAY..mw_base b ON e.id_base=b.id_base
INNER JOIN CI_MIDDLEWAY..to_admin_user_base taub ON e.id_base=taub.id_base
INNER JOIN CI_MIDDLEWAY..ticketoffice_pairdevice topd ON taub.id_to_admin_user=topd.id_ticketoffice_user
WHERE
topd.code=@code
    AND DATEADD(minute, ((0)*-1), CONVERT(VARCHAR(10),ap.dt_apresentacao,121) + ' ' + REPLACE(ap.hr_apresentacao, 'h', ':') + ':00.000')>=GETDATE()
    AND e.in_ativo=1
ORDER BY e.ds_evento
