CREATE PROCEDURE dbo.pr_room_save (
    @CodSala INT
    ,@NomSala VARCHAR(1000)
    ,@NomRedSala VARCHAR(12)
    ,@nameonsite VARCHAR(1000)
    ,@IngressoNumerado BIT
    ,@id_local_evento INT
    ,@StaSala VARCHAR(1)
)

AS

SET NOCOUNT ON;

DECLARE @has BIT = 0;

IF @CodSala != 0
BEGIN
    SELECT @has = 1 FROM tabSala WHERE CodSala=@CodSala;
END

DECLARE @hasLE BIT = 0
SELECT @hasLE=1 FROM CI_MIDDLEWAY..mw_local_evento le WHERE le.id_local_evento=@id_local_evento

IF @hasLE = 0
BEGIN
    SELECT 0 success
            ,'Falha ao tentar localizar o local do evento' msg
            ,@CodSala id
END

IF @has = 1
BEGIN
    UPDATE [dbo].[tabSala]
    SET id_local_evento=@id_local_evento
        ,NomSala=@NomSala
        ,NomRedSala=@NomRedSala
        ,nameonsite=@nameonsite
        ,IngressoNumerado=@IngressoNumerado
        ,StaSala=@StaSala
    WHERE CodSala=@CodSala;
END
ELSE
BEGIN
    DECLARE @idDB INT
    SELECT @idDB=MAX(CodSala)+1 FROM tabSala
    IF @idDB IS NULL
    BEGIN
        SET @idDB = 1
    END
    SET @CodSala =@idDB

    INSERT INTO [dbo].[tabSala]
            (CodSala
            ,NomSala
            ,NomRedSala
            ,nameonsite
            ,IngressoNumerado
            ,id_local_evento
            ,StaSala)
        VALUES
            (@CodSala
            ,@NomSala
            ,@NomRedSala
            ,@nameonsite
            ,@IngressoNumerado
            ,@id_local_evento
            ,'A')

END

SELECT 1 success
        ,'Salvo com sucesso' msg
        ,@CodSala id