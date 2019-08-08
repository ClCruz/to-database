-- exec sp_executesql N'EXEC pr_room_sectors_add @P1,@P2,@P3,@P4',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000)',N'4',N'teste',N'3.21',N'#134f5c'
delete from tabSetor where CodSala=4
delete from tabsala where CodSala=4

CREATE PROCEDURE dbo.pr_room_sectors_add (@codSala INT
                                            ,@name VARCHAR(1000)
                                            ,@value FLOAT
                                            ,@color VARCHAR(100))

AS

SET NOCOUNT ON;

DECLARE @hasName BIT = 0


SELECT @hasName = 1 FROM tabSetor s WHERE s.CodSala=@codSala AND s.NomSetor=@name AND s.[Status]='A'

IF @hasName = 1
BEGIN
    SELECT 0 success
            ,'Já existe um setor com esse nome para essa sala.' msg
    RETURN;
END
ELSE
BEGIN
    DECLARE @idDB INT
    SELECT @idDB=MAX(CodSetor)+1 FROM tabSetor
    IF @idDB IS NULL
    BEGIN
        SET @idDB = 1
    END

    INSERT INTO tabSetor (CodSetor,CodSala,CorSetor,NomSetor,PerDesconto,[Status])
        SELECT @idDB, @codSala, @color, @name, @value, 'A'
END

SELECT 1 success
        ,'Salvo com sucesso.' msg

