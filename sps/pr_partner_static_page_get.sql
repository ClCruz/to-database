ALTER PROCEDURE dbo.pr_partner_static_page_get (@api VARCHAR(100), @id_static_page INT)

AS

-- DECLARE @api VARCHAR(100) = 'live_578abaf329f84119bb7c1e55dfdc7e0f4f20e693cd2c4bc7a5bc0a0965fae322'
--         ,@id_static_page INT = 1

SET NOCOUNT ON;

DECLARE @id_partner UNIQUEIDENTIFIER

SELECT TOP 1 @id_partner=p.id FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api


SELECT
sp.id
,sp.name
,psp.isvisible
,CONVERT(VARCHAR(10),psp.created,103) + ' ' + CONVERT(VARCHAR(8),psp.created,114) created
,(CASE WHEN psp.changed IS NULL THEN '' ELSE CONVERT(VARCHAR(10),psp.changed,103) + ' ' + CONVERT(VARCHAR(8),psp.changed,114) END) changed
,psp.title
,psp.content
FROM CI_MIDDLEWAY..static_page sp
INNER JOIN CI_MIDDLEWAY..partner_static_page psp ON sp.id=psp.id_static_page 
WHERE psp.id_partner=@id_partner
AND psp.id_static_page=@id_static_page
ORDER BY sp.id