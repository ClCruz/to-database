ALTER PROCEDURE dbo.pr_place_select (@api VARCHAR(100), @id_city INT)

AS

SET NOCOUNT ON;

DECLARE @id_partner UNIQUEIDENTIFIER

SELECT TOP 1 @id_partner=p.id FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api

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
INNER JOIN CI_MIDDLEWAY..partner_local_evento ple ON le.id_local_evento=ple.id_local_evento
WHERE le.id_municipio=@id_city
AND ple.id_partner=@id_partner
ORDER BY le.ds_local_evento