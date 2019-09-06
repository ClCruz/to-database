ALTER PROCEDURE dbo.pr_accountingdebittype_get (@id INT)

AS

SET NOCOUNT ON;

SELECT 
  tdb.Ativo
  ,tdb.CodTipBilhete
  ,tdb.CodTipDebBordero
  ,tdb.DebBordero
  ,tdb.in_DescontaCartao
  ,tdb.PerDesconto
  ,tdb.QtdLimiteIngrParaVenda
  ,tdb.StaDebBordero
  ,tdb.StaDebBorderoLiq
  ,tdb.TipValor
  ,tdb.ValIngressoExcedente
  ,tdb.VlMinimo
  ,ISNULL(tdb.sell_channel,'all') sell_channel
FROM [dbo].tabTipDebBordero tdb
WHERE tdb.CodTipDebBordero=@id