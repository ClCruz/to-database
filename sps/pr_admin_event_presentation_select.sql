CREATE PROCEDURE dbo.pr_admin_event_presentation_select (@id_evento INT)

AS

-- DECLARE @id_evento INT = 33153

SET NOCOUNT ON;

SELECT
    CONVERT(VARCHAR(10),ap.dt_apresentacao,103) dt_apresentacao
    ,ap.hr_apresentacao
    ,ap.ds_piso
    ,ap.id_apresentacao
FROM CI_MIDDLEWAY..mw_apresentacao ap
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
WHERE ap.id_evento=@id_evento AND ap.in_ativo=1
ORDER BY ap.dt_apresentacao --DESC