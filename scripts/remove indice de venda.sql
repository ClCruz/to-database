BEGIN TRAN
--COMMIT
--ROLLBACK
IF OBJECT_ID('tempdb.dbo.#helper', 'U') IS NOT NULL
    DROP TABLE #helper; 
-- select * from CI_MIDDLEWAY..mw_item_pedido_venda where id_pedido_venda=981
-- select * from CI_MIDDLEWAY..mw_apresentacao_bilhete where id_apresentacao=167685

SELECT
ls.Indice
,ls.StaCadeira
,sd.NomObjeto 
,ls.CodReserva
,895 numLancamento
,19929 CodCliente
,'LF4BOCAOGC' codVenda
,49123257 id_apresentacao_bilhete
,1 codTipBilhete
,ls.CodApresentacao
,s.NomSala
,s.NomRedSala
,a.CodPeca
,sd.CodSetor
,a.HorSessao
,a.DatApresentacao
,se.NomSetor
,212 id_base
,a.CodSala
,238.6 valor
,ROW_NUMBER() OVER (order by ls.indice) [number]
,1073 id_pedido_venda
,12297829 id_reserva
,ap.id_apresentacao
,'INTEIRA' ds_nome_site
,140.0 VL_UNITARIO
,21.0 VL_TAXA_CONVENIENCIA
INTO #helper
from ciadeingressos..tabLugSala ls
INNER JOIN ciadeingressos..tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao
INNER JOIN ciadeingressos..tabSala s ON a.CodSala=s.CodSala
INNER JOIN ciadeingressos..tabSalDetalhe sd ON ls.Indice=sd.Indice AND sd.CodSala=a.CodSala
INNER JOIN ciadeingressos..tabSetor se ON se.CodSala=sd.CodSala AND se.CodSetor=sd.CodSetor
INNER JOIN CI_MIDDLEWAY..mw_evento e ON a.CodPeca=e.CodPeca AND e.id_base=212
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento AND a.CodApresentacao=ap.CodApresentacao
INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete apb ON ap.id_apresentacao=apb.id_apresentacao AND apb.in_ativo=1 AND apb.CodTipBilhete=1
where-- ls.CodApresentacao=4 
--and 
ls.StaCadeira='V'-- and ls.Indice in (select Indice from ciadeingressos..tabResCliente where CodCliente=19888)
AND ls.CodVenda='LF4BOCAOGC'
AND ls.Indice=19021

DELETE d
FROM  tabLugSala d
INNER JOIN #helper h ON d.CodApresentacao=h.codapresentacao AND d.Indice=h.indice

DELETE d
FROM  tabLancamento d
INNER JOIN #helper h ON d.CodApresentacao=h.codapresentacao AND d.Indice=h.indice

DELETE d
FROM  tabHisCliente d
INNER JOIN #helper h ON d.CodApresentacao=h.codapresentacao AND d.Indice=h.indice

DELETE d
FROM  tabControleSeqVenda d
INNER JOIN #helper h ON d.CodApresentacao=h.codapresentacao AND d.Indice=h.indice

DELETE d
FROM  tabIngresso d
INNER JOIN #helper h ON d.CodVenda=h.codVenda AND d.Indice=h.indice

DELETE d
FROM  CI_MIDDLEWAY..MW_ITEM_PEDIDO_VENDA d
INNER JOIN #helper h ON d.Indice=h.indice AND d.id_pedido_venda=h.id_pedido_venda

