CREATE PROCEDURE dbo.pr_place_save (@id_local_evento INT
,@ds_local_evento VARCHAR(50)
,@id_tipo_local INT
,@id_municipio INT
,@in_ativo BIT
,@ds_googlemaps VARCHAR(1000))

AS

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
    WHERE le.id_tipo_local=@id_local_evento
END