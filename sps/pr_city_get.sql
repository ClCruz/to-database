CREATE PROCEDURE dbo.pr_city_get (@id INT)

AS

SET NOCOUNT ON;

SELECT 
  m.id_municipio
  ,m.ds_municipio
  ,m.id_estado
  ,m.img
  ,m.img_extra
FROM CI_MIDDLEWAY..mw_municipio m
WHERE m.id_municipio=@id