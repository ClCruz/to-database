CREATE PROCEDURE dbo.pr_accountingdebittype_get (@id INT)

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
FROM [dbo].tabTipDebBordero tdb
WHERE tdb.CodTipDebBordero=@id