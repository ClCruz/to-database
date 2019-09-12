CREATE PROCEDURE dbo.pr_purchase_web_ticket_log_list (@id_pedido_venda INT)

AS
-- DECLARE @id_pedido_venda INT = 7513

SELECT
tl.id
,tl.[type]
,tau.[login]
,CONVERT(VARCHAR(10),tl.created,103) + ' ' + CONVERT(VARCHAR(8),tl.created,114) created
FROM CI_MIDDLEWAY..purchase_web_ticket_log tl
INNER JOIN CI_MIDDLEWAY..to_admin_user tau ON tl.id_to_admin_user=tau.id
WHERE tl.id_pedido_venda=@id_pedido_venda
ORDER BY tl.created DESC