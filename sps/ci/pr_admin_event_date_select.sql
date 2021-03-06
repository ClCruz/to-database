ALTER PROCEDURE dbo.pr_admin_event_date_select (@id_evento INT)

AS

-- DECLARE @id_evento INT = 33153

SET NOCOUNT ON;

SELECT DISTINCT
    CONVERT(VARCHAR(10),a.DatApresentacao,103) DatApresentacao
    ,a.DatApresentacao [date]
FROM CI_MIDDLEWAY..mw_apresentacao ap
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
WHERE ap.id_evento=@id_evento AND ap.in_ativo=1
ORDER BY [date] --DESC