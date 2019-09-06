ALTER PROCEDURE dbo.pr_accountingdebittype_save (@CodTipDebBordero INT
      ,@DebBordero varchar(40)
      ,@PerDesconto float
      ,@StaDebBordero VARCHAR(1)
      ,@TipValor VARCHAR(1)
      ,@Ativo VARCHAR(1)
      ,@VlMinimo float
      ,@StaDebBorderoLiq VARCHAR(1)
      ,@QtdLimiteIngrParaVenda int
      ,@ValIngressoExcedente numeric(10,2)
      ,@CodTipBilhete smallint
      ,@in_DescontaCartao VARCHAR(1)
      ,@sell_channel VARCHAR(50)
)

AS

SET NOCOUNT ON;

DECLARE @has BIT = 0;

IF @VlMinimo = 0
    SET @VlMinimo = NULL

IF @QtdLimiteIngrParaVenda = 0
    SET @QtdLimiteIngrParaVenda = NULL

IF @ValIngressoExcedente = 0
    SET @ValIngressoExcedente = NULL

IF @CodTipBilhete = 0
    SET @CodTipBilhete = NULL

IF @sell_channel = 'all'
    SET @sell_channel = NULL

IF @CodTipDebBordero != 0
BEGIN
    SELECT @has = 1 FROM tabTipDebBordero WHERE CodTipDebBordero=@CodTipDebBordero;
END

IF @has = 1
BEGIN

UPDATE [dbo].[tabTipDebBordero]
   SET
      [DebBordero] = @DebBordero
      ,[PerDesconto] = @PerDesconto
      ,[StaDebBordero] = @StaDebBordero
      ,[TipValor] = @TipValor
      ,[Ativo] = @Ativo
      ,[VlMinimo] = @VlMinimo
      ,[StaDebBorderoLiq] = @StaDebBorderoLiq
      ,[QtdLimiteIngrParaVenda] = @QtdLimiteIngrParaVenda
      ,[ValIngressoExcedente] = @ValIngressoExcedente
      ,[CodTipBilhete] = @CodTipBilhete
      ,[in_DescontaCartao] = @in_DescontaCartao
      ,[sell_channel]=@sell_channel
 WHERE CodTipDebBordero=@CodTipDebBordero

END
ELSE
BEGIN
    DECLARE @idDB INT
    SELECT @idDB=MAX(CodTipDebBordero)+1 FROM tabTipDebBordero
    IF @idDB IS NULL
    BEGIN
        SET @idDB = 1
    END
    SET @CodTipDebBordero=@idDB

    INSERT INTO [dbo].[tabTipDebBordero]
            ([CodTipDebBordero]
            ,[DebBordero]
            ,[PerDesconto]
            ,[StaDebBordero]
            ,[TipValor]
            ,[Ativo]
            ,[VlMinimo]
            ,[StaDebBorderoLiq]
            ,[QtdLimiteIngrParaVenda]
            ,[ValIngressoExcedente]
            ,[CodTipBilhete]
            ,[in_DescontaCartao]
            ,[sell_channel])
        VALUES
            (@CodTipDebBordero
            ,@DebBordero
            ,@PerDesconto
            ,'A'
            ,@TipValor
            ,'A'
            ,@VlMinimo
            ,@StaDebBorderoLiq
            ,@QtdLimiteIngrParaVenda
            ,@ValIngressoExcedente
            ,@CodTipBilhete
            ,@in_DescontaCartao
            ,@sell_channel)

END

SELECT 1 success
        ,'Salvo com sucesso' msg
        ,@CodTipDebBordero id