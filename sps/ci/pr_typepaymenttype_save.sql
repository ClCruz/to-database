CREATE PROCEDURE dbo.pr_typepaymenttype_save (@CodTipForPagto INT
,@ClassifPagtoSAP VARCHAR(10)
,@StaTipForPagto VARCHAR(1)
,@TipForPagto VARCHAR(1000)
)

AS


SET NOCOUNT ON;

DECLARE @has BIT = 0;

IF @CodTipForPagto != 0
BEGIN
    SELECT @has = 1 FROM tabTipForPagamento WHERE CodTipForPagto=@CodTipForPagto;
END

IF @has = 1
BEGIN
    UPDATE [dbo].[tabTipForPagamento]
    SET [TipForPagto] = @TipForPagto
        ,[StaTipForPagto] = @StaTipForPagto
        ,[ClassifPagtoSAP] = @ClassifPagtoSAP
    WHERE [CodTipForPagto] = @CodTipForPagto
END
ELSE
BEGIN
    DECLARE @idDB INT
    SELECT @idDB=MAX(CodTipForPagto)+1 FROM tabTipForPagamento
    IF @idDB IS NULL
    BEGIN
        SET @idDB = 1
    END
    SET @CodTipForPagto =@idDB


    INSERT INTO [dbo].[tabTipForPagamento]
            ([CodTipForPagto]
            ,[TipForPagto]
            ,[StaTipForPagto]
            ,[StaImprComprovante]
            ,[ClassifPagtoSAP])
        VALUES
            (@CodTipForPagto
            ,@TipForPagto
            ,@StaTipForPagto
            ,'N'
            ,@ClassifPagtoSAP)

END

SELECT 1 success
        ,'Salvo com sucesso' msg
        ,@CodTipForPagto id