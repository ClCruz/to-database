CREATE PROCEDURE dbo.pr_admin_event_getbase(@id_evento INT)

AS

SELECT TOP 1 id_base
FROM CI_MIDDLEWAY..mw_evento 
WHERE id_evento=@id_evento