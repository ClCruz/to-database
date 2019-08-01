-- exec sp_executesql N'EXEC pr_paymenttype_save @P1,@P2,@P3,@P4,@P5,@P6,@P7,@P8,@P9,@P10,@P11,@P12',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000),@P7 nvarchar(4000),@P8 nvarchar(4000),@P9 nvarchar(4000),@P10 nvarchar(4000),@P11 nvarchar(4000),@P12 nvarchar(4000)',N'',N'',N'52',N'teste',N'1.25',N'5',N'1',N'N',N'A',N'S',N'N',N'C'

ALTER PROCEDURE dbo.pr_paymenttype_save (@CodForPagto INT
  ,@CodBanco char(3)
  ,@CodTipForPagto INT
  ,@ForPagto VARCHAR(100)
  ,@PcTxAdm MONEY
  ,@PrzRepasseDias INT
  ,@showorder INT
  ,@StaDebBordLiq CHAR(1)
  ,@StaForPagto char(1)
  ,@StaPagarMe char(1)
  ,@StaTaxaCartoes char(1)
  ,@TipCaixa char(1)
)

AS

SET NOCOUNT ON;

DECLARE @has BIT = 0;

IF @CodBanco = 0
    SET @CodBanco = NULL

IF @CodForPagto != 0
BEGIN
    SELECT @has = 1 FROM tabForPagamento WHERE CodForPagto=@CodForPagto;
END

IF @has = 1
BEGIN
    UPDATE [dbo].[tabForPagamento]
    SET [CodTipForPagto] = @CodTipForPagto
        ,[ForPagto] = @ForPagto
        ,[CodBanco] = @CodBanco
        ,[StaForPagto] = @StaForPagto
        ,[TipCaixa] = @TipCaixa
        ,[PcTxAdm] = @PcTxAdm
        ,[PrzRepasseDias] = @PrzRepasseDias
        ,[StaDebBordLiq] = @StaDebBordLiq
        ,[StaTaxaCartoes] = @StaTaxaCartoes
        ,[StaPagarMe] = @StaPagarMe
        ,[showorder] = @showorder
    WHERE CodForPagto=@CodForPagto;
END
ELSE
BEGIN
    DECLARE @idDB INT
    SELECT @idDB=MAX(CodForPagto)+1 FROM tabForPagamento
    IF @idDB IS NULL
    BEGIN
        SET @idDB = 1
    END
    SET @CodForPagto =@idDB

    INSERT INTO [dbo].[tabForPagamento]
            ([CodForPagto]
            ,[CodTipForPagto]
            ,[ForPagto]
            ,[CodBanco]
            ,[StaForPagto]
            ,[TipCaixa]
            ,[PcTxAdm]
            ,[PrzRepasseDias]
            ,[StaDebBordLiq]
            ,[StaTaxaCartoes]
            ,[StaPagarMe]
            ,[showorder])
        VALUES
            (@CodForPagto
            ,@CodTipForPagto
            ,@ForPagto
            ,@CodBanco
            ,'A'
            ,@TipCaixa
            ,@PcTxAdm
            ,@PrzRepasseDias
            ,@StaDebBordLiq
            ,@StaTaxaCartoes
            ,@StaPagarMe
            ,@showorder)

END

SELECT 1 success
        ,'Salvo com sucesso' msg
        ,@CodForPagto id