CREATE PROCEDURE dbo.pr_quotapartner_select (@api VARCHAR(100))

AS

SET NOCOUNT ON;

DECLARE @id_partner UNIQUEIDENTIFIER

SELECT TOP 1 @id_partner=p.id FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api

SELECT
g.id
,g.[name]
,g.active
FROM CI_MIDDLEWAY..quota_partner g
WHERE g.active=1
AND g.id_partner=@id_partner
ORDER BY [name]