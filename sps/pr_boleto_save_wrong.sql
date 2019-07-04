ALTER PROCEDURE dbo.pr_boleto_save_wrong (@id_pedido_venda INT)

AS


UPDATE CI_MIDDLEWAY..mw_pedido_venda SET isboletogenerated=1 WHERE id_pedido_venda=@id_pedido_venda