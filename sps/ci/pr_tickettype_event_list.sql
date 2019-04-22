ALTER PROCEDURE dbo.pr_tickettype_event_list (@id_evento INT)

AS

-- DECLARE @id_evento INT = 33016

SET NOCOUNT ON;

DECLARE @codPeca INT

SELECT @codPeca=codPeca FROM CI_MIDDLEWAY..mw_evento WHERE id_evento=@id_evento

SELECT
vb.CodPeca
,vb.CodTipBilhete
,CONVERT(VARCHAR(10),vb.DatIniDesconto,103) DatIniDesconto
,CONVERT(VARCHAR(10),vb.DatFinDesconto,103) DatFinDesconto
,tb.TipBilhete
,tb.nameTicketOffice
,tb.nameWeb
,tb.isAllotment
,tb.isDiscount
,tb.isFixed
,tb.isHalf
,tb.isPlus
,tb.isPrincipal
,tb.allowweb
,tb.allowticketoffice
,tb.PerDesconto
,tb.vl_preco_fixo
FROM tabValBilhete vb
INNER JOIN tabPeca p ON vb.CodPeca=p.CodPeca
INNER JOIN tabTipBilhete tb ON vb.CodTipBilhete=tb.CodTipBilhete
WHERE vb.CodPeca=@codPeca
AND tb.isOld=0
ORDER BY tb.StaTipBilhete, tb.isPrincipal DESC, tb.isDiscount DESC, tb.isHalf DESC, tb.isFixed DESC, tb.isAllotment DESC, tb.isPlus DESC, vb.DatIniDesconto, tb.TipBilhete