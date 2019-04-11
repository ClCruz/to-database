ALTER PROCEDURE dbo.pr_to_admin_user_auth_list (@id UNIQUEIDENTIFIER)

AS

SELECT
taa.id
,taa.[group]
,taa.code
,taa.name
,taa.[description]
,(CASE WHEN taau.id_admin_user IS NULL THEN 0 ELSE taau.active END) active
FROM CI_MIDDLEWAY..to_admin_authorization taa
LEFT JOIN CI_MIDDLEWAY..to_admin_authorization_user taau ON taa.id=taau.id_admin_authorization AND taau.id_admin_user=@id
ORDER BY taa.[group], taa.name