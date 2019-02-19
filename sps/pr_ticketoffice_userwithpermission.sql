ALTER PROCEDURE dbo.pr_ticketoffice_userwithpermission (@id_base INT)

AS

SELECT DISTINCT
    tau.id
    ,tau.[login]
    ,tau.name
    ,tau.email
FROM CI_MIDDLEWAY..to_admin_user tau
INNER JOIN CI_MIDDLEWAY..to_admin_user_base taub ON tau.id=taub.id_to_admin_user
INNER JOIN CI_MIDDLEWAY..to_admin_authorization_user taau ON tau.id=taau.id_admin_user
INNER JOIN CI_MIDDLEWAY..to_admin_authorization taa ON taau.id_admin_authorization=taa.id
WHERE taa.code='ticketoffice-login'
AND taub.id_base=@id_base
AND tau.active=1
ORDER BY [login], [name]