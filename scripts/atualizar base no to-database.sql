SELECT 
'"ci_model",' [name]
UNION ALL
SELECT
'"'+ds_nome_base_sql+'",' [name]
FROM CI_MIDDLEWAY..mw_base
WHERE in_ativo=1
order by [name]