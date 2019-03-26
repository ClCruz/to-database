CREATE PROCEDURE dbo.pr_partner_static_page_check (@api VARCHAR(100))

AS

-- DECLARE @api VARCHAR(100) = 'live_578abaf329f84119bb7c1e55dfdc7e0f4f20e693cd2c4bc7a5bc0a0965fae322'

SET NOCOUNT ON;

DECLARE @id_partner UNIQUEIDENTIFIER

SELECT TOP 1 @id_partner=p.id FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api


SELECT
sp.id
,sp.name
,(CASE WHEN psp.id IS NULL THEN 0 ELSE psp.isvisible END) isvisible
FROM CI_MIDDLEWAY..static_page sp
LEFT JOIN CI_MIDDLEWAY..partner_static_page psp ON sp.id=psp.id_static_page AND psp.id_partner=@id_partner
ORDER BY sp.id