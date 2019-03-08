CREATE PROCEDURE dbo.pr_user_documenttype

AS

SELECT
id_doc_estrangeiro id
,'Estrangeiro: '+ds_doc_estrangeiro [name]
,1 [order]
,'' mask
FROM CI_MIDDLEWAY..mw_doc_estrangeiro
UNION ALL
SELECT 0, 'CPF', 0 [order], '###.###.###-##'
ORDER BY [order], [name]