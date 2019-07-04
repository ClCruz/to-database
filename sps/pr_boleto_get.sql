ALTER PROCEDURE dbo.pr_boleto_get (@id_pedido_venda INT)

AS

-- DECLARE @id_pedido_venda INT = 3149

SELECT
pv.cd_numero_transacao
,pv.isboletogenerated
,pv.url_boleto
,h.host
,h.name
FROM CI_MIDDLEWAY..mw_pedido_venda pv
INNER JOIN CI_MIDDLEWAY..order_host oh ON oh.id_pedido_venda=pv.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..host h ON oh.id_host=h.id
WHERE pv.id_pedido_venda=@id_pedido_venda