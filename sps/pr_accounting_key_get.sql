ALTER PROCEDURE dbo.pr_accounting_key_get (@id UNIQUEIDENTIFIER)

AS

SET NOCOUNT ON;

SELECT
ak.[password]
,ak.used
,ak.id_evento
FROM CI_MIDDLEWAY..accounting_key ak
WHERE ak.id=@id