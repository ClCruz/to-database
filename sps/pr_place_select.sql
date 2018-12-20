CREATE PROCEDURE dbo.pr_place_select (@id_city INT)

AS

SELECT
le.id_local_evento
,le.ds_local_evento
,le.ds_googlemaps
,le.in_ativo
,m.ds_municipio
,e.sg_estado
,e.ds_estado
,tl.ds_tipo_local

FROM CI_MIDDLEWAY..mw_local_evento le
INNER JOIN CI_MIDDLEWAY..mw_municipio m ON le.id_municipio=m.id_municipio
INNER JOIN CI_MIDDLEWAY..mw_estado e ON m.id_estado=e.id_estado
INNER JOIN CI_MIDDLEWAY..mw_tipo_local tl ON le.id_tipo_local=tl.id_tipo_local
WHERE le.id_municipio=@id_city
ORDER BY le.ds_local_evento