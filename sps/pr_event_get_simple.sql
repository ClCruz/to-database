CREATE PROCEDURE dbo.pr_event_get_simple(@id_evento INT)

AS


SELECT
e.ds_evento
FROM CI_MIDDLEWAY..mw_evento e
WHERE e.id_evento=@id_evento