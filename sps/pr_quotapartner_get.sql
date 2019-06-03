ALTER PROCEDURE dbo.pr_quotapartner_get (@id UNIQUEIDENTIFIER)

AS

SET NOCOUNT ON;

SELECT
g.id
,g.[name]
,g.[key]
,g.active
FROM CI_MIDDLEWAY..quota_partner g
WHERE g.id=@id