ALTER PROCEDURE dbo.pr_city (@id_state INT)

AS

SELECT
m.id_municipio
,m.ds_municipio
FROM CI_MIDDLEWAY..mw_municipio m
WHERE m.id_estado=@id_state
ORDER BY m.ds_municipio