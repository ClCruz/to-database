CREATE PROCEDURE dbo.pr_typepaymenttype_select

AS


SET NOCOUNT ON;

SELECT 
  tfp.CodTipForPagto
  ,tfp.ClassifPagtoSAP
  ,tfp.StaImprComprovante
  ,tfp.StaTipForPagto
  ,tfp.TipForPagto
  ,DB_NAME() uniquename
FROM [dbo].tabTipForPagamento tfp
WHERE tfp.StaTipForPagto='A'
ORDER BY tfp.TipForPagto
