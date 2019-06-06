CREATE PROCEDURE dbo.pr_recover_base_by_pedido (@id_pedido_venda INT)

AS

SET NOCOUNT ON;

DECLARE @id_base INT = NULL

SELECT @id_base=e.id_base
FROM CI_MIDDLEWAY..mw_item_pedido_venda ipv
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON ipv.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
WHERE ipv.id_pedido_venda=@id_pedido_venda

SELECT @id_base id_base