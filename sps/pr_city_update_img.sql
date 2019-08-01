CREATE PROCEDURE dbo.pr_city_update_img (@id_municipio INT
  ,@img VARCHAR(4000)
  ,@img_extra VARCHAR(4000)
)

AS

SET NOCOUNT ON;

UPDATE CI_MIDDLEWAY..mw_municipio
SET img=ISNULL(@img,img)
    ,img_extra=ISNULL(@img_extra,img_extra)
WHERE id_municipio=@id_municipio

SELECT 1 success
        ,'Salvo com sucesso' msg