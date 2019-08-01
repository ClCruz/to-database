-- exec sp_executesql N'EXEC pr_city_save @P1,@P2,@P3',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000)',N'',N'26',N'Teste'


-- ALTER PROCEDURE dbo.pr_city_save (@id_municipio INT
--   ,@ds_municipio VARCHAR(50)
--   ,@id_estado INT
-- )

-- AS

DECLARE @id_municipio INT = ''
  ,@ds_municipio VARCHAR(50) = 'teste'
  ,@id_estado INT = 26

SET NOCOUNT ON;

IF @id_municipio != 0
BEGIN
    UPDATE CI_MIDDLEWAY..mw_municipio
    SET ds_municipio=@ds_municipio
        ,id_estado=@id_estado
    WHERE id_municipio=@id_municipio
END
ELSE
BEGIN
    INSERT INTO CI_MIDDLEWAY..mw_municipio(ds_municipio,id_estado,img,img_extra)
        VALUES
            (@ds_municipio
            ,@id_estado
            ,null
            ,null)

    SET @id_municipio = @@IDENTITY;

END

SELECT 1 success
        ,'Salvo com sucesso' msg
        ,@id_municipio id