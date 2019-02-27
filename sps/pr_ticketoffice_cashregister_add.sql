ALTER PROCEDURE dbo.pr_ticketoffice_cashregister_add (
        @id_base INT
        ,@id_ticketoffice_user UNIQUEIDENTIFIER
        ,@type VARCHAR(100)
        ,@amount INT
        ,@justification VARCHAR(100))

AS

-- DECLARE @amount INT = 5300
--         ,@id_ticketoffice_user UNIQUEIDENTIFIER = 'f2177e5e-f727-4906-948d-4eea9b9bbd0e'
--         ,@type VARCHAR(100) = 'withdraw'
--         ,@id_base INT = 213
--         ,@justification VARCHAR(100) = 'teste'

SET NOCOUNT ON;

DECLARE @codForPagto INT = 52
        ,@id_evento INT = NULL
        ,@codVenda VARCHAR(10) = NULL
        ,@id UNIQUEIDENTIFIER = NEWID()
        ,@created DATETIME = GETDATE()

IF @type = 'cashdepositopen'
BEGIN
    SET @justification='Abertura de caixa'
END

IF len(@justification)=''
BEGIN
    SELECT 0 success
            ,'Justificativa é obrigatória.' msg
            , null id
            , null created
    RETURN;
END

IF @amount<0
BEGIN
    SELECT 0 success
            ,'Valor não pode ser menor que zero.' msg
            , null id
            , null created
    RETURN;
END

IF @type = 'withdraw'
BEGIN
    DECLARE @positiveTotal INT = 0
            ,@negativeTotal INT = 0
            ,@total INT = 0

    SELECT @positiveTotal = SUM(amount) FROM CI_MIDDLEWAY..ticketoffice_cashregister_moviment WHERE isopen=1 AND id_ticketoffice_user=@id_ticketoffice_user AND id_base=@id_base AND codForPagto=@codForPagto AND [type] NOT IN ('withdraw','refund')
    SELECT @negativeTotal = ISNULL(SUM(amount),0) FROM CI_MIDDLEWAY..ticketoffice_cashregister_moviment WHERE isopen=1 AND id_ticketoffice_user=@id_ticketoffice_user AND id_base=@id_base AND codForPagto=@codForPagto AND [type] IN ('withdraw','refund')

    SET @total = @positiveTotal-@negativeTotal;

    SET @total = @total-@amount

    IF @total<0
    BEGIN
        SELECT 0 success
                ,'Você não tem saldo suficiente para realizar esse saque.' msg
                ,null id
                ,null created
        RETURN;
    END
END

INSERT INTO CI_MIDDLEWAY..ticketoffice_cashregister_moviment(id,created,amount,codForPagto,codVenda,id_base,id_evento,isopen,[type],id_ticketoffice_user, justification)
SELECT @id,@created, @amount, @codForPagto, @codVenda, @id_base, @id_evento, 1, @type, @id_ticketoffice_user, @justification

SELECT 1 success
        ,'Executado com sucesso' msg
        ,@id id
        ,CONVERT(VARCHAR(10),@created,103) + ' ' + CONVERT(VARCHAR(8),@created,114) [created]