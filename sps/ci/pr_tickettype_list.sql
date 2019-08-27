ALTER PROCEDURE dbo.pr_tickettype_list (@text VARCHAR(100), @currentPage INT = 1, @perPage INT = 10)

AS

-- declare @text VARCHAR(100) = NULL, @currentPage INT = 1, @perPage INT = 10

DECLARE @principal BIT = NULL
        ,@fixed BIT = NULL
        ,@half BIT = NULL
        ,@plus BIT = NULL
        ,@discount BIT = NULL
        ,@pos BIT = NULL
        ,@free BIT = NULL
        ,@allotment BIT = NULL
        ,@alloweb BIT = NULL
        ,@allowticketoffice BIT = NULL
        ,@allowapi BIT = NULL

IF @text = '@alloweb' OR @text = '@web'
BEGIN
    SET @text = ''
    SET @alloweb = 1
END

IF @text = '@allowticketoffice' OR @text = '@bilheteria'
BEGIN
    SET @text = ''
    SET @allowticketoffice = 1
END

IF @text = '@allowapi' OR @text = '@api'
BEGIN
    SET @text = ''
    SET @allowapi = 1
END

IF @text = '@principal' OR @text = '@inteira'
BEGIN
    SET @text = ''
    SET @principal = 1
END

IF @text = '@fixed' OR @text = '@fixa'
BEGIN
    SET @text = ''
    SET @fixed = 1
END

IF @text = '@half' OR @text = '@meia'
BEGIN
    SET @text = ''
    SET @half = 1
END

IF @text = '@discount' OR @text = '@desconto'
BEGIN
    SET @text = ''
    SET @discount = 1
END

IF @text = '@pos'
BEGIN
    SET @text = ''
    SET @pos = 1
END

IF @text = '@free' OR @text = '@gratuito'
BEGIN
    SET @text = ''
    SET @free = 1
END


IF @text = '@plus' OR @text = '@outras' OR @text = '@mais' OR @text = '@combo'
BEGIN
    SET @text = ''
    SET @plus = 1
END

IF @text = '@allotment' OR @text = '@lote'
BEGIN
    SET @text = ''
    SET @allotment = 1
END

SELECT 
  tb.CodTipBilhete
  ,tb.TipBilhete
  ,tb.nameWeb
  ,tb.nameTicketOffice
  ,tb.nameAPI
  ,tb.isFixed
  ,tb.isPrincipal
  ,tb.isHalf
  ,tb.isPlus
  ,tb.isAllotment
  ,tb.isDiscount
  ,tb.isNoValue
  ,tb.isPOS
  ,tb.allowweb
  ,tb.allowticketoffice
  ,tb.allowapi
  ,tb.StaTipBilhete
  ,COUNT(*) OVER() totalCount
  ,@currentPage currentPage
FROM [dbo].tabTipBilhete tb
WHERE tb.TipBilhete NOT IN ('Temporário', 'MW_PLANETGIRLS')  --tb.isOld=0
AND ((@text IS NULL OR tb.TipBilhete like '%'+@text+'%') 
        OR (@text IS NULL OR tb.nameWeb like '%'+@text+'%') 
        OR (@text IS NULL OR tb.nameTicketOffice like '%'+@text+'%')
        OR (@text IS NULL OR tb.nameAPI like '%'+@text+'%'))
-- OR (@text IS NULL OR title like '%'+@text+'%')
-- OR (@text IS NULL OR content like '%'+@text+'%')
-- OR (@text IS NULL OR link like '%'+@text+'%')
AND (@principal IS NULL OR tb.isPrincipal=1)
AND (@fixed IS NULL OR tb.isFixed=1)
AND (@half IS NULL OR tb.isHalf=1)
AND (@discount IS NULL OR tb.isDiscount=1)
AND (@plus IS NULL OR tb.isPlus=1)
AND (@free IS NULL OR tb.isNoValue=1)
AND (@pos IS NULL OR tb.isPOS=1)
AND (@allotment IS NULL OR tb.isAllotment=1)
AND (@alloweb IS NULL OR tb.allowweb=1)
AND (@allowticketoffice IS NULL OR tb.allowticketoffice=1)
AND (@allowapi IS NULL OR tb.allowapi=1)
ORDER BY tb.StaTipBilhete, tb.isPrincipal DESC, tb.isDiscount DESC, tb.isHalf DESC, tb.isFixed DESC, tb.isAllotment DESC, tb.isPlus DESC, tb.TipBilhete
OFFSET (@currentPage-1)*@perPage ROWS
  FETCH NEXT @perPage ROWS ONLY;

-- --   select * from tabTipBilhete
-- --   update tabTipBilhete set isold=1 where CodTipBilhete in (0, 2,3,6)