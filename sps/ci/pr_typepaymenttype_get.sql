CREATE PROCEDURE dbo.pr_typepaymenttype_get (@id INT)

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
WHERE tfp.CodTipForPagto=@id