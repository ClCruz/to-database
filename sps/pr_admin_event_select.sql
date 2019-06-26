
ALTER PROCEDURE dbo.pr_admin_event_select (@id_user UNIQUEIDENTIFIER, @id_base INT)

AS
-- DECLARE @id_user UNIQUEIDENTIFIER = 'F2177E5E-F727-4906-948D-4EEA9B9BBD0E', @id_base INT = 213

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
    ,eei.showonline
    ,(CASE WHEN EXISTS(SELECT 1 FROM CI_MIDDLEWAY..mw_apresentacao sub WHERE sub.id_evento=e.id_evento AND sub.dt_apresentacao>=GETDATE()) THEN 1 ELSE 0 END) hasshowyet
    ,le.ds_local_evento
    ,g.name genreName
    ,m.ds_municipio
    ,es.ds_estado
    ,es.sg_estado
    ,e.id_base
    ,CONVERT(VARCHAR(10),eei.created,103) + ' ' + CONVERT(VARCHAR(8),eei.created,114) [created]
    ,COUNT(*) OVER() totalCount
FROM CI_MIDDLEWAY..mw_evento e
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..mw_local_evento le ON e.id_local_evento=le.id_local_evento
INNER JOIN CI_MIDDLEWAY..to_admin_user_base taub ON e.id_base=taub.id_base AND taub.id_to_admin_user=@id_user AND taub.active=1
LEFT JOIN CI_MIDDLEWAY..mw_municipio m ON m.id_municipio=le.id_municipio
LEFT JOIN CI_MIDDLEWAY..mw_estado es ON m.id_estado=es.id_estado
LEFT JOIN CI_MIDDLEWAY..genre g ON eei.id_genre=g.id
WHERE e.id_base=@id_base
ORDER by LTRIM(e.ds_evento)
