CREATE PROCEDURE dbo.pr_paymenttype_list (@text VARCHAR(100) = NULL, @currentPage INT = 1, @perPage INT = 10)

AS


SELECT 
  fp.CodBanco
  ,fp.CodForPagto
  ,fp.CodTipForPagto
  ,fp.ForPagto
  ,fp.PcTxAdm
  ,fp.PrzRepasseDias
  ,fp.showorder
  ,fp.StaDebBordLiq
  ,fp.StaForPagto
  ,fp.StaPagarMe
  ,fp.StaTaxaCartoes
  ,fp.TipCaixa
  ,@currentPage currentPage
  ,COUNT(*) OVER() totalCount
FROM [dbo].tabForPagamento fp
WHERE ((@text IS NULL OR fp.TipCaixa like '%'+@text+'%'))
AND fp.StaForPagto='A'
ORDER BY fp.TipCaixa
OFFSET (@currentPage-1)*@perPage ROWS
  FETCH NEXT @perPage ROWS ONLY;

