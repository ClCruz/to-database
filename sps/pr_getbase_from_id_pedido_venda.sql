CREATE PROCEDURE dbo.pr_getbase_from_id_pedido_venda (@id_pedido_venda INT)

AS

-- DECLARE @id_pedido_venda INT = 283, @uniquename VARCHAR(100) = 'localhost'

SET NOCOUNT ON;

DECLARE @id_base INT = 0


SELECT TOP 1
@id_base = e.id_base
FROM CI_MIDDLEWAY..mw_pedido_venda pv
INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON pv.id_pedido_venda=ipv.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON ipv.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
WHERE pv.id_pedido_venda=@id_pedido_venda

SELECT @id_base id_base