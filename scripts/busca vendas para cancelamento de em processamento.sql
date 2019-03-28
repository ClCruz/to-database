-- select * from CI_MIDDLEWAY..mw_evento where ds_evento like '%VALE%PENA%'
-- select * from CI_MIDDLEWAY..mw_base where id_base=236
-- select * from tambemvou..tabLugSala where CodVenda='ZM4GBOEOGO'
-- select * from CI_MIDDLEWAY..mw_item_pedido_venda where CodVenda='ZNDOCOEACO'
-- select * from CI_MIDDLEWAY..mw_pedido_venda where id_pedido_venda=513

SELECT DISTINCT
ls.Indice
,ls.StaCadeira
,ls.CodApresentacao
,ls.CodVenda
,a.HorSessao
,a.DatApresentacao
,p.NomPeca
,sd.NomObjeto
,pv.id_pedido_venda
,pv.in_situacao
,cli.ds_nome + ' ' + cli.ds_sobrenome nome
FROM tambemvou..tabLugSala ls
INNER JOIN tambemvou..tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao
INNER JOIN tambemvou..tabSalDetalhe sd ON ls.Indice=sd.Indice AND sd.CodSala=a.CodSala
INNER JOIN tambemvou..tabPeca p ON a.CodPeca=p.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca AND e.id_base=236
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento AND a.CodApresentacao=ap.CodApresentacao
LEFT JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ls.CodVenda=ipv.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS AND ipv.id_apresentacao=ap.id_apresentacao
LEFT JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda
LEFT JOIN CI_MIDDLEWAY..mw_cliente cli ON pv.id_cliente=cli.id_cliente
WHERE ls.CodApresentacao=22
AND ls.StaCadeira='V'
--ORDER BY ipv.id_pedido_venda, ls.CodVenda, sd.NomObjeto, ls.Indice
-- AND

-- 504 / ZC4GCGEODO
-- 507 / ZM4GBOEOGO

-- COLLATE SQL_Latin1_General_CP1_CI_AS