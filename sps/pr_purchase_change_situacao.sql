CREATE PROCEDURE dbo.pr_purchase_change_situacao (@id_pedido_venda INT)

AS

UPDATE CI_MIDDLEWAY..mw_pedido_venda
    SET in_situacao = 'F'
WHERE
    id_pedido_venda = @id_pedido_venda