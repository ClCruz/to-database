
SELECT id_cliente, my, p.uniquename 
into #teste
FROM (SELECT
id_cliente
,(SELECT TOP 1 sub3.name FROM CI_MIDDLEWAY..mw_pedido_venda sub 
INNER JOIN CI_MIDDLEWAY..order_host sub2 ON sub.id_pedido_venda=sub2.id_pedido_venda 
INNER JOIN CI_MIDDLEWAY..host sub3 ON sub2.id_host=sub3.id
WHERE sub.id_cliente=cl.id_cliente) my
FROM CI_MIDDLEWAY..mw_cliente cl
WHERE cl.uniquename_partner IS NULL) as t
LEFT JOIN CI_MIDDLEWAY..[partner] p ON (CASE t.my WHEN 'sazarte' THEN 'sazarteingressos' WHEN 'tixs.me' THEN 'tixsme' WHEN 'ci_localhost' THEN 'localhost' ELSE t.my END) =p.uniquename
WHERE my IS NOT NULL
-- select * from CI_MIDDLEWAY..partner order by uniquename

-- tixsme
-- sazarteingressos

UPDATE d
SET d.uniquename_partner=t.uniquename
FROM CI_MIDDLEWAY..mw_cliente d
INNER JOIN #teste t ON d.id_cliente=t.id_cliente