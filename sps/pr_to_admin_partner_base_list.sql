-- pr_to_admin_partner_base_list '2F6DD49B-3292-4E64-A7A6-D725CDC7FF83'

CREATE PROCEDURE dbo.pr_to_admin_partner_base_list (@id UNIQUEIDENTIFIER)

AS

SELECT
b.id_base
,b.ds_nome_base_sql
,b.ds_nome_teatro
,(CASE WHEN pdb.id IS NULL THEN 0 ELSE 1 END) active
FROM CI_MIDDLEWAY..mw_base b
LEFT JOIN CI_MIDDLEWAY..partner_database pdb ON b.id_base=pdb.id_base AND pdb.id_partner=@id
WHERE b.in_ativo=1