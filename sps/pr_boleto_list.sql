ALTER PROCEDURE dbo.pr_boleto_list

AS

SELECT DISTINCT --TOP 25
pv.id_pedido_venda
,h.name
FROM CI_MIDDLEWAY..mw_pedido_venda pv
INNER JOIN CI_MIDDLEWAY..order_host oh ON oh.id_pedido_venda=pv.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..host h ON oh.id_host=h.id
WHERE pv.isboletogenerated IS NULL AND pv.url_boleto IS NULL AND pv.cd_numero_transacao IS NOT NULL
-- WHERE pv.id_pedido_venda in (3149,3151,3152,3190,3192,3193)
-- WHERE pv.id_pedido_venda in (3163) 
AND [name] != 'ci_localhost'