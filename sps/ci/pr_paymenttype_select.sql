CREATE PROCEDURE dbo.pr_paymenttype_select

AS


SET NOCOUNT ON;

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
FROM [dbo].tabForPagamento fp
WHERE fp.StaForPagto='A'
ORDER BY fp.ForPagto
