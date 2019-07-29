ALTER PROCEDURE dbo.pr_to_admin_user_base_list (@id UNIQUEIDENTIFIER)

AS

SELECT
b.id_base
,b.ds_nome_base_sql
,b.ds_nome_teatro
,(CASE WHEN pdb.id IS NULL THEN 0 ELSE pdb.active END) active
FROM CI_MIDDLEWAY..mw_base b
LEFT JOIN CI_MIDDLEWAY..to_admin_user_base pdb ON b.id_base=pdb.id_base AND pdb.id_to_admin_user=@id
WHERE b.in_ativo=1
ORDER BY b.ds_nome_base_sql