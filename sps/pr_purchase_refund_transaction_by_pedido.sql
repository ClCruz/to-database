CREATE PROCEDURE dbo.pr_purchase_refund_transaction_by_pedido (@id_pedido_venda INT)

AS

SELECT
pv.cd_numero_transacao
FROM CI_MIDDLEWAY..mw_pedido_venda pv
WHERE pv.id_pedido_venda=@id_pedido_venda
AND id_pedido_ipagare='pagarme'
AND in_situacao IN ('F','P')