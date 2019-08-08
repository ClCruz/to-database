CREATE PROCEDURE dbo.pr_room_sectors_remove (@codSala INT
                                            ,@codSetor INT)

AS

SET NOCOUNT ON;

DECLARE @has BIT = 0


SELECT @has = 1 FROM tabSetor s WHERE s.CodSala=@codSala AND s.CodSetor=@codSetor

IF @has = 0
BEGIN
    SELECT 0 success
            ,'Não foi possível encontrar o setor selecionado.' msg
    RETURN;
END
ELSE
BEGIN
    UPDATE tabSetor SET [Status]='I' WHERE CodSala=@codSala AND CodSetor=@codSetor
END

SELECT 1 success
        ,'Removido com sucesso.' msg

