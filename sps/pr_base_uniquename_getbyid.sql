
CREATE PROCEDURE dbo.pr_base_uniquename_getbyid (@id_base INT)

AS

SELECT ds_nome_base_sql FROM CI_MIDDLEWAY..mw_base
WHERE id_base=@id_base