--exec sp_executesql N'EXEC pr_place_save @P1, @P2, @P3, @P4, @P5, @P6',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000)',N'',N'Local de Teste',N'R. Dr. Carvalho de Mendonça, 777 - Marapé, Santos - SP, 11070-103',N'1',N'4',N'13'
--exec sp_executesql N'EXEC pr_place_save @P1, @P2, @P3, @P4, @P5, @P6',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000)',N'857',N'Local de Teste',N'13',N'4',N'1',N'R. Dr. Carvalho de Mendonça, 777 - Marapé, Santos - SP, 11070-103'

ALTER PROCEDURE dbo.pr_place_save (@id_local_evento INT
,@ds_local_evento VARCHAR(50)
,@id_tipo_local INT
,@id_municipio INT
,@in_ativo BIT
,@ds_googlemaps VARCHAR(1000))

AS

IF @id_local_evento = ''
    SET @id_local_evento = NULL

IF @id_local_evento IS NULL
BEGIN
    INSERT INTO CI_MIDDLEWAY..mw_local_evento (ds_local_evento,id_tipo_local,id_municipio,in_ativo,ds_googlemaps)
    VALUES (@ds_local_evento,@id_tipo_local,@id_municipio,@in_ativo,@ds_googlemaps);
END
ELSE
BEGIN
    UPDATE le
        SET le.ds_local_evento=@ds_local_evento
            ,le.id_tipo_local=@id_tipo_local
            ,le.id_municipio=@id_municipio
            ,le.in_ativo=@in_ativo
            ,le.ds_googlemaps=@ds_googlemaps
    FROM CI_MIDDLEWAY..mw_local_evento le
    WHERE le.id_local_evento=@id_local_evento
END