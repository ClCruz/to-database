CREATE PROCEDURE dbo.pr_ticketoffice_getmodelbysell(@codVenda VARCHAR(10))

AS

-- DECLARE @codVenda VARCHAR(10) = 'Y64AIOCBGO'

SET NOCOUNT ON;

DECLARE @id_base INT
SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

SELECT TOP 1 eei.ticketoffice_ticketmodel
FROM tabLugSala ls
INNER JOIN tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao
INNER JOIN tabPeca p ON a.CodPeca=p.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca AND e.id_base=@id_base
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento AND ap.CodApresentacao=a.CodApresentacao
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN tabLancamento l ON ls.CodApresentacao=l.CodApresentacao AND ls.Indice=l.Indice AND l.CodTipLancamento=1 AND l.NumLancamento NOT IN (SELECT sub.NumLancamento FROM tablancamento sub WHERE sub.indice=ls.Indice AND sub.CodApresentacao=ls.codapresentacao AND sub.CodTipLancamento=2)
INNER JOIN CI_MIDDLEWAY..mw_produtor pro ON p.id_produtor=pro.id_produtor
LEFT JOIN CI_MIDDLEWAY..mw_local_evento le ON e.id_local_evento=le.id_local_evento
LEFT JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosch ON ls.Indice=tosch.indice AND ap.id_apresentacao=tosch.id_apresentacao
LEFT JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.Indice=ls.Indice AND ipv.id_apresentacao=ap.id_apresentacao
LEFT JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda
LEFT JOIN tabTipBilhete tb ON l.CodTipBilhete=tb.CodTipBilhete
LEFT JOIN tabForPagamento fp ON l.CodForPagto=fp.CodForPagto
LEFT JOIN tabTipForPagamento tfp ON fp.CodTipForPagto=tfp.CodTipForPagto
LEFT JOIN tabHisCliente hc ON l.NumLancamento=hc.NumLancamento AND ls.CodApresentacao=hc.CodApresentacao AND ls.Indice=hc.Indice
LEFT JOIN tabCliente c ON hc.Codigo=c.Codigo
LEFT JOIN CI_MIDDLEWAY..ticketoffice_user tou ON tosch.id_ticketoffice_user=tou.id
LEFT JOIN tabControleSeqVenda csv ON ls.Indice=csv.Indice AND ls.CodApresentacao=csv.CodApresentacao AND csv.statusingresso IN ('L','V')
WHERE ls.CodVenda=@codVenda