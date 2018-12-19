--pr_admin_authorization 'f2177e5e-f727-4906-948d-4eea9b9bbd0e'



CREATE PROCEDURE dbo.pr_admin_authorization (@id_admin_user UNIQUEIDENTIFIER)

AS

SELECT
taa.code
FROM CI_MIDDLEWAY..to_admin_authorization_user taau
INNER JOIN CI_MIDDLEWAY..to_admin_authorization taa ON taau.id_admin_authorization=taa.id
WHERE taau.id_admin_user=@id_admin_user
AND taau.active=1
ORDER BY taa.code