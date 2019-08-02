CREATE PROCEDURE dbo.pr_accountingdebittype_select

AS


SET NOCOUNT ON;

SELECT 
  tdb.Ativo
  ,tdb.CodTipBilhete
  ,tdb.CodTipDebBordero
  ,tdb.DebBordero
  ,tdb.in_DescontaCartao
  ,tdb.PerDesconto
  ,FORMAT(CONVERT(DECIMAL(12,2),(tdb.PerDesconto)), 'N', 'pt-br') PerDesconto_formatted
  ,tdb.QtdLimiteIngrParaVenda
  ,tdb.StaDebBordero
  ,tdb.StaDebBorderoLiq
  ,tdb.TipValor
  ,tdb.ValIngressoExcedente
  ,tdb.VlMinimo
FROM [dbo].tabTipDebBordero tdb
WHERE tdb.StaDebBordero='A'
ORDER BY tdb.DebBordero
