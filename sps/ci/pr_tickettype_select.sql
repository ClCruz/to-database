-- -- ALTER PROCEDURE dbo.pr_tickettype_select (@showto VARCHAR(100), @principal BIT = 0, @fixed BIT = 0, @discount BIT = 0, @half BIT = 0, @plus BIT = 0, @allotment BIT = 0)

-- -- AS

DECLARE @showto VARCHAR(100) = 'all', @principal BIT = 0, @fixed BIT = 0, @half BIT = 0, @plus BIT = 0, @allotment BIT = 0, @discount BIT = 0, @free BIT = 0, @pos BIT = 0

SET NOCOUNT ON;

DECLARE @allowweb BIT = 0, @allowticketoffice BIT = 0

IF @showto = 'web'
BEGIN
    SET @allowweb = 1;
    SET @allowticketoffice = 0;
END

IF @showto = 'ticketoffice'
BEGIN
    SET @allowweb = 0;
    SET @allowticketoffice = 1;
END

-- update tabTipBilhete set allowweb=1 where CodTipBilhete=4
SELECT 
  tb.CodTipBilhete
  ,tb.TipBilhete
  ,tb.isFixed
  ,tb.isPrincipal
  ,tb.isHalf
  ,tb.isDiscount
  ,tb.isPlus
  ,tb.isAllotment
  ,tb.isNoValue
  ,tb.isPOS
  ,tb.hasImage
  ,tb.[description]
  ,(CASE WHEN @showto = 'web' THEN tb.nameWeb ELSE tb.nameTicketOffice END) [name]
  ,(CASE WHEN tb.isFixed = 1 THEN tb.vl_preco_fixo*100 ELSE 0 END) fixed_amount
  ,tb.PerDesconto
  ,tb.vl_preco_fixo
FROM [dbo].tabTipBilhete tb
WHERE tb.isOld=0
AND tb.StaTipBilhete='A'
AND (@allowweb = 0 OR tb.allowweb=@allowweb)
AND (@allowticketoffice = 0 OR tb.allowticketoffice=@allowticketoffice)
AND ((@principal = 0 OR tb.isPrincipal=1)
AND (@fixed = 0 OR tb.isFixed=1)
AND (@half = 0 OR tb.isHalf=1)
AND (@discount = 0 OR tb.isDiscount=1)
AND (@plus = 0 OR tb.isPlus=1)
AND (@free = 0 OR tb.isNoValue=1)
AND (@pos = 0 OR tb.isPos=1)
AND (@allotment = 0 OR tb.isAllotment=1))
ORDER BY tb.isPrincipal DESC, tb.isDiscount DESC, tb.isHalf DESC, tb.isFixed DESC, tb.isAllotment DESC, tb.isPlus DESC, tb.TipBilhete
