ALTER PROCEDURE dbo.pr_ticketoffice_cashregister_close (
        @id_base INT
        ,@id_ticketoffice_user UNIQUEIDENTIFIER
        ,@amount VARCHAR(MAX)
        ,@justification VARCHAR(100))

AS

-- DECLARE @id_base INT = 213
--         ,@id_ticketoffice_user UNIQUEIDENTIFIER = 'f2177e5e-f727-4906-948d-4eea9b9bbd0e'
--         ,@amount VARCHAR(MAX) = '53#-100|52#-400'
--         ,@justification VARCHAR(100) = 'testee'

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#amount', 'U') IS NOT NULL
    DROP TABLE #amount; 

CREATE TABLE #amount (id INT, amount INT);

IF @amount IS NOT NULL AND @amount <> ''
BEGIN
    INSERT INTO #amount (id, amount)
    SELECT SUBSTRING(Item,1,CHARINDEX('#',Item)-1), CONVERT(INT,SUBSTRING(Item,CHARINDEX('#',Item)+1,LEN(Item))) FROM dbo.splitString(@amount, '|')
END

INSERT INTO CI_MIDDLEWAY..ticketoffice_cashregister_moviment(amount,codForPagto,codVenda,id_base,id_evento,isopen,[type],id_ticketoffice_user, justification)
SELECT amount, id, '', @id_base, NULL, 1, 'diff', @id_ticketoffice_user, @justification FROM #amount

DECLARE @id_cr UNIQUEIDENTIFIER = NULL
        ,@has BIT = 0

SELECT @id_cr=id, @has=1 FROM CI_MIDDLEWAY..ticketoffice_cashregister WHERE id_ticketoffice_user=@id_ticketoffice_user AND id_base=@id_base AND isopen=1


IF @has = 0
BEGIN
    SELECT 0 success
            ,'Não foi possível fechar o caixa, o mesmo encontra-se fechado.' msg
            ,NULL id
    RETURN;
END

UPDATE d
SET d.closed = GETDATE()
        ,d.isopen=0
        ,d.id_ticketoffice_user_closed=@id_ticketoffice_user
        ,d.justification_closed = @justification
FROM CI_MIDDLEWAY..ticketoffice_cashregister d
WHERE d.id=@id_cr


UPDATE d
SET d.id_ticketoffice_cashregister=@id_cr
    ,d.isopen=0
FROM CI_MIDDLEWAY..ticketoffice_cashregister_moviment d
WHERE d.id_ticketoffice_user=@id_ticketoffice_user
    AND d.isopen=1
    AND d.id_base=@id_base


SELECT 1 success
        ,'Caixa fechado com sucesso.' msg
        ,@id_cr id