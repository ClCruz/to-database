--pr_event_local_byid 43879

ALTER PROCEDURE dbo.pr_event_local_byid (@id_evento INT)

AS

SET NOCOUNT ON;
-- DECLARE @id_evento INT = 43879

SELECT TOP 1
eei.id_evento
,e.ds_evento
,le.ds_googlemaps
,le.ds_local_evento
FROM CI_MIDDLEWAY..mw_evento_extrainfo eei
INNER JOIN CI_MIDDLEWAY..mw_evento e ON eei.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_base b ON e.id_base=b.id_base
INNER JOIN CI_MIDDLEWAY..mw_local_evento le ON le.id_local_evento=e.id_local_evento
LEFT JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento AND ap.in_ativo=1
WHERE eei.id_evento=@id_evento
GROUP BY 
eei.id_evento
,e.ds_evento
,le.ds_googlemaps
,le.ds_local_evento
ORDER BY eei.id_evento DESC