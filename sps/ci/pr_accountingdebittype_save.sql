-- exec sp_executesql N'EXEC pr_accountingdebittype_save @P1,@P2,@P3,@P4,@P5,@P6,@P7,@P8,@P9,@P10,@P11,@P12',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000),@P7 nvarchar(4000),@P8 nvarchar(4000),@P9 nvarchar(4000),@P10 nvarchar(4000),@P11 char(1),@P12 nvarchar(4000)',N'',N'testing',N'1.23',N'A',N'V',N'A',N'0',N'S',N'',N'0',NULL,N'N'
-- N''
-- N'testing'
-- N'1.23'
-- N'A'
-- N'V'
-- N'A'
-- N'0'
-- N'S'
-- N''
-- N''
-- NULL
-- N'N'

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
            ,[in_DescontaCartao])
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
            ,@in_DescontaCartao)

END

SELECT 1 success
        ,'Salvo com sucesso' msg
        ,@CodTipDebBordero id