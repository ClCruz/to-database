CREATE PROCEDURE dbo.pr_partner_list_withpermission (@id_to_admin_user UNIQUEIDENTIFIER)

AS

-- DECLARE @id_to_admin_user UNIQUEIDENTIFIER = 'f2177e5e-f727-4906-948d-4eea9b9bbd0e'


SELECT
p.[key]
,p.name
,p.uniquename
FROM CI_MIDDLEWAY..[partner] p
INNER JOIN CI_MIDDLEWAY..mw_base b ON p.uniquename=b.ds_nome_base_sql
INNER JOIN CI_MIDDLEWAY..to_admin_user_base taub ON taub.id_base=b.id_base
WHERE p.active=1
AND taub.id_to_admin_user=@id_to_admin_user
ORDER BY [name]