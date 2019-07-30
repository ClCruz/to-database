CREATE PROCEDURE dbo.pr_typepaymenttype_list (@text VARCHAR(100) = NULL, @currentPage INT = 1, @perPage INT = 10)

AS


SELECT 
  tfp.CodTipForPagto
  ,tfp.ClassifPagtoSAP
  ,tfp.StaImprComprovante
  ,tfp.StaTipForPagto
  ,tfp.TipForPagto
  ,DB_NAME() uniquename
  ,@currentPage currentPage
  ,COUNT(*) OVER() totalCount
FROM [dbo].tabTipForPagamento tfp
WHERE ((@text IS NULL OR tfp.TipForPagto like '%'+@text+'%'))
AND tfp.StaTipForPagto='A'
ORDER BY tfp.TipForPagto
OFFSET (@currentPage-1)*@perPage ROWS
  FETCH NEXT @perPage ROWS ONLY;