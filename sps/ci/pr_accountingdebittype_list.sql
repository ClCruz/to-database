ALTER PROCEDURE dbo.pr_accountingdebittype_list (@text VARCHAR(100) = NULL, @currentPage INT = 1, @perPage INT = 10)

AS

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
  ,(CASE WHEN tdb.TipValor = 'V' THEN 'Por valor'
         WHEN tdb.TipValor = 'P' THEN 'Por porcentagem'
         WHEN tdb.TipValor = 'F' THEN 'Por valor fixo' END) TipValorDesc
  ,@currentPage currentPage
  ,COUNT(*) OVER() totalCount
FROM [dbo].tabTipDebBordero tdb
WHERE ((@text IS NULL OR tdb.DebBordero like '%'+@text+'%'))
ORDER BY tdb.DebBordero
OFFSET (@currentPage-1)*@perPage ROWS
  FETCH NEXT @perPage ROWS ONLY;

