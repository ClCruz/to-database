CREATE PROCEDURE dbo.pr_show_partner_info_bypedido (@api VARCHAR(1000)
        ,@id_pedido_venda INT)

AS

-- DECLARE @api VARCHAR(1000)
--         ,@id_pedido_venda INT

SET NOCOUNT ON;

DECLARE @show_partner_info BIT

SELECT TOP 1 @show_partner_info=p.show_partner_info FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api

SELECT TOP 1
b.ds_nome_base_sql
,@show_partner_info show_partner_info
FROM CI_MIDDLEWAY..mw_item_pedido_venda ipv
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON ipv.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_base b ON e.id_base=b.id_base
WHERE ipv.id_pedido_venda=@id_pedido_venda