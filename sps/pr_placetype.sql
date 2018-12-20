CREATE PROCEDURE dbo.pr_placetype

AS

SELECT
tl.id_tipo_local
,tl.ds_tipo_local
FROM CI_MIDDLEWAY..mw_tipo_local tl
ORDER BY tl.ds_tipo_local