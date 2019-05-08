ALTER PROCEDURE dbo.pr_to_admin_user_base_select (@id_user UNIQUEIDENTIFIER)

AS

SELECT
b.id_base
,b.ds_nome_teatro
,b.ds_nome_base_sql
FROM CI_MIDDLEWAY..mw_base b
INNER JOIN CI_MIDDLEWAY..to_admin_user_base taub ON b.id_base=taub.id_base AND taub.active=1
WHERE id_to_admin_user=@id_user
ORDER BY b.ds_nome_teatro