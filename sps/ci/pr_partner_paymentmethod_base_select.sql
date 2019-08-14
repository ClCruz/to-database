ALTER PROCEDURE dbo.pr_partner_paymentmethod_base_select

AS

SELECT
fp.CodForPagto
,fp.ForPagto
FROM tabForPagamento fp
WHERE StaForPagto='A'
ORDER BY fp.ForPagto