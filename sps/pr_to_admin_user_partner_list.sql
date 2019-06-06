ALTER PROCEDURE dbo.pr_to_admin_user_partner_list (@id UNIQUEIDENTIFIER)

AS

-- DECLARE @id UNIQUEIDENTIFIER = 'f2177e5e-f727-4906-948d-4eea9b9bbd0e'

SELECT
p.id
,p.name
,p.domain
,(CASE WHEN aup.id IS NULL THEN 0 ELSE aup.active END) active
FROM CI_MIDDLEWAY..[partner] p
LEFT JOIN CI_MIDDLEWAY..to_admin_user_partner aup ON p.id=aup.id_partner AND aup.id_to_admin_user=@id
WHERE p.dateEnd IS NULL OR p.dateEnd>=GETDATE()
ORDER BY p.name