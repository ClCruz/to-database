ALTER PROCEDURE dbo.pr_site_place_get (@name VARCHAR(100))

AS

-- DECLARE @name VARCHAR(100) = 'gillans_inn_english_rock_bar'
-- Teatro Madre Esperança Garrido

SELECT TOP 1
le.id_local_evento
,le.ds_local_evento
,le.id_tipo_local
,le.id_municipio
,ISNULL(le.ds_googlemaps, le.ds_local_evento) ds_googlemaps
,le.[url]
,le.ticketbox_info
,le.occupation_info
,le.meta_description
,le.meta_keywords
,le.in_ativo
,m.id_estado
,m.ds_municipio
,e.sg_estado
,e.ds_estado
,tl.ds_tipo_local
FROM CI_MIDDLEWAY..mw_local_evento le
INNER JOIN CI_MIDDLEWAY..mw_municipio m ON le.id_municipio=m.id_municipio
INNER JOIN CI_MIDDLEWAY..mw_estado e ON m.id_estado=e.id_estado
INNER JOIN CI_MIDDLEWAY..mw_tipo_local tl ON le.id_tipo_local=tl.id_tipo_local
-- WHERE ds_local_evento like '%cubas%'
WHERE REPLACE(ds_local_evento,'''','') COLLATE SQL_Latin1_General_CP1_CI_AI like '%'+@name+'%' COLLATE SQL_Latin1_General_CP1_CI_AI
-- AND le.in_ativo=1
ORDER BY le.id_local_evento DESC
-- Teatro Municipal Brás Cubas