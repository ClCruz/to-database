
CREATE PROCEDURE dbo.pr_admin_event (@id_user UNIQUEIDENTIFIER, @search VARCHAR(100) = NULL, @currentPage INT = 1, @perPage INT = 10)

AS

SET NOCOUNT ON;

SELECT
    e.id_evento
    ,e.id_base
    ,e.CodPeca
    ,e.id_local_evento
    ,e.in_ativo
    ,e.ds_evento
    ,eei.showInBanner
    ,eei.cardimage
    ,eei.uri
    ,le.ds_local_evento
    ,g.name
    ,m.ds_municipio
    ,es.ds_estado
    ,es.sg_estado
    ,CONVERT(VARCHAR(10),eei.created,103) + ' ' + CONVERT(VARCHAR(8),eei.created,114) [created]
    -- ,COUNT(*) OVER() totalCount
    -- ,@currentPage currentPage
FROM CI_MIDDLEWAY..mw_evento e
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..mw_local_evento le ON e.id_local_evento=le.id_local_evento
INNER JOIN CI_MIDDLEWAY..to_admin_user_base taub ON e.id_base=taub.id_base AND taub.id_to_admin_user=@id_user
LEFT JOIN CI_MIDDLEWAY..mw_municipio m ON m.id_municipio=le.id_municipio
LEFT JOIN CI_MIDDLEWAY..mw_estado es ON m.id_estado=es.id_estado
LEFT JOIN CI_MIDDLEWAY..genre g ON eei.id_genre=g.id
WHERE (@search IS NULL OR e.ds_evento LIKE '%'+@search+'%')
OR (@search IS NULL OR le.ds_local_evento LIKE '%'+@search+'%')
ORDER by e.ds_evento
 OFFSET (@currentPage-1)*@perPage ROWS
    FETCH NEXT @perPage ROWS ONLY;