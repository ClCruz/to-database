-- exec sp_executesql N'EXEC pr_room_save @P1,@P2,@P3,@P4,@P5,@P6,@P7',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 int,@P6 nvarchar(4000),@P7 nvarchar(4000)',N'',N's1',N's1ss',N's1s',1,N'613',N'A'
ALTER PROCEDURE dbo.pr_room_save (
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
            ,StaSala
            ,CadNumerada)
        VALUES
            (@CodSala
            ,@NomSala
            ,@NomRedSala
            ,@nameonsite
            ,@IngressoNumerado
            ,@id_local_evento
            ,'A'
            ,0)

END

SELECT 1 success
        ,'Salvo com sucesso' msg
        ,@CodSala id