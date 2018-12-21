ALTER PROCEDURE dbo.pr_place_get (@id_place INT)

AS

SELECT
le.id_local_evento
,le.ds_local_evento
,le.ds_googlemaps
,le.in_ativo
,le.id_municipio
,le.id_tipo_local
,m.id_estado
,m.ds_municipio
,e.sg_estado
,e.ds_estado
,tl.ds_tipo_local
FROM CI_MIDDLEWAY..mw_local_evento le
INNER JOIN CI_MIDDLEWAY..mw_municipio m ON le.id_municipio=m.id_municipio
INNER JOIN CI_MIDDLEWAY..mw_estado e ON m.id_estado=e.id_estado
INNER JOIN CI_MIDDLEWAY..mw_tipo_local tl ON le.id_tipo_local=tl.id_tipo_local
WHERE le.id_local_evento=@id_place