--pr_ticketoffice_shoppingcart_result 'acca6ac6-8e05-4f18-9b7b-507dcad696ac'

ALTER PROCEDURE dbo.pr_ticketoffice_shoppingcart_result (@id UNIQUEIDENTIFIER)

AS

-- DECLARE @id UNIQUEIDENTIFIER = 'F2177E5E-F727-4906-948D-4EEA9B9BBD0E'

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#result', 'U') IS NOT NULL
    DROP TABLE #result; 

SELECT DISTINCT
tosc.id_apresentacao
,tosc.indice
,tosc.id_event
,tosc.id_base
,tosc.amount
,tosc.amount_discount
,tosc.amount_topay
,tosc.created
,tosc.quantity
,tosc.id_payment_type
,tosc.id_ticket_type
,sd.NomObjeto
,se.NomSetor
,se.PerDesconto
,ls.StaCadeira
,0 amountSubTotalSector
,0 amountSubTotalTicket
,(CASE WHEN tosc.id_ticket_type IS NULL THEN 0 ELSE 1 END) valid
,tpb.TipBilhete
,tpb.PerDesconto PerDescontoTipBilhete
,(CASE WHEN tpb.vl_preco_fixo IS NULL OR tpb.vl_preco_fixo = 0 THEN 0 ELSE 1 END) isFixedAmount
INTO #result
FROM CI_MIDDLEWAY.dbo.ticketoffice_shoppingcart tosc
INNER JOIN CI_MIDDLEWAY.dbo.mw_apresentacao ap ON tosc.id_apresentacao=ap.id_apresentacao
INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN tabSetor se ON s.CodSala=se.CodSala
INNER JOIN tabSalDetalhe sd ON s.CodSala=sd.CodSala AND tosc.indice=sd.Indice AND sd.CodSetor=se.CodSetor
INNER JOIN tabLugSala ls ON ap.CodApresentacao=ls.CodApresentacao AND tosc.indice=ls.Indice
LEFT JOIN tabTipBilhete tpb ON tosc.id_ticket_type=tpb.CodTipBilhete
WHERE id_ticketoffice_user=@id
ORDER BY se.NomSetor, sd.NomObjeto

SELECT
id_apresentacao
,indice
,id_event
,id_base
,(CASE WHEN isFixedAmount = 1 THEN amount_topay ELSE amount END) amount
,amount_discount
,amount_topay
,created
,quantity
,id_payment_type
,id_ticket_type
,NomObjeto
,NomSetor
,PerDesconto
,StaCadeira
,amountSubTotalSector
,amountSubTotalTicket
,valid
,TipBilhete
,PerDesconto PerDescontoTipBilhete
,isFixedAmount
FROM #result