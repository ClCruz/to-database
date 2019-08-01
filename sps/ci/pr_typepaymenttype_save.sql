CREATE PROCEDURE dbo.pr_paymenttype_save (@CodForPagto INT

  ,@CodBanco
  ,@CodForPagto
  ,@CodTipForPagto
  ,@ForPagto
  ,@PcTxAdm
  ,@PrzRepasseDias
  ,@showorder
  ,@StaDebBordLiq
  ,@StaForPagto
  ,@StaPagarMe
  ,@StaTaxaCartoes
  ,@TipCaixa


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

    USE [ci_localhost]
GO

UPDATE [dbo].[tabForPagamento]
   SET [CodForPagto] = <CodForPagto, tinyint,>
      ,[CodTipForPagto] = <CodTipForPagto, tinyint,>
      ,[ForPagto] = <ForPagto, varchar(30),>
      ,[CodBanco] = <CodBanco, char(3),>
      ,[StaForPagto] = <StaForPagto, char(1),>
      ,[TipCaixa] = <TipCaixa, char(1),>
      ,[PcTxAdm] = <PcTxAdm, money,>
      ,[PrzRepasseDias] = <PrzRepasseDias, int,>
      ,[StaDebBordLiq] = <StaDebBordLiq, char(1),>
      ,[StaTaxaCartoes] = <StaTaxaCartoes, char(1),>
      ,[StaPagarMe] = <StaPagarMe, char(1),>
      ,[showorder] = <showorder, int,>
 WHERE <Search Conditions,,>
GO


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


USE [ci_localhost]
GO

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
           (<CodForPagto, tinyint,>
           ,<CodTipForPagto, tinyint,>
           ,<ForPagto, varchar(30),>
           ,<CodBanco, char(3),>
           ,<StaForPagto, char(1),>
           ,<TipCaixa, char(1),>
           ,<PcTxAdm, money,>
           ,<PrzRepasseDias, int,>
           ,<StaDebBordLiq, char(1),>
           ,<StaTaxaCartoes, char(1),>
           ,<StaPagarMe, char(1),>
           ,<showorder, int,>)
GO



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