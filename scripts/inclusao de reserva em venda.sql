BEGIN TRAN
--COMMIT
--ROLLBACK
IF OBJECT_ID('tempdb.dbo.#helper', 'U') IS NOT NULL
    DROP TABLE #helper; 

-- select * from tabIngresso where Indice=26577
-- select * from tabLancamento where Indice=26577 
-- select * from tabHisCliente where NumLancamento=430
-- select * from CI_MIDDLEWAY..mw_item_pedido_venda where id_pedido_venda=664
-- select * from CI_MIDDLEWAY..mw_apresentacao_bilhete where id_apresentacao=167685


SELECT
ls.Indice
,ls.StaCadeira
,sd.NomObjeto 
,ls.CodReserva
,430 numLancamento
,19641 CodCliente
,'1ROHEOFFDO' codVenda
,49123258 id_apresentacao_bilhete
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
,460 valor
,ROW_NUMBER() OVER (order by ls.indice) [number]
,664 id_pedido_venda
,12297829 id_reserva
,ap.id_apresentacao
,'INTEIRA' ds_nome_site
,100.0 VL_UNITARIO
,15.0 VL_TAXA_CONVENIENCIA
INTO #helper
from ciadeingressos..tabLugSala ls
INNER JOIN ciadeingressos..tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao
INNER JOIN ciadeingressos..tabSala s ON a.CodSala=s.CodSala
INNER JOIN ciadeingressos..tabSalDetalhe sd ON ls.Indice=sd.Indice AND sd.CodSala=a.CodSala
INNER JOIN ciadeingressos..tabSetor se ON se.CodSala=sd.CodSala AND se.CodSetor=sd.CodSetor
INNER JOIN CI_MIDDLEWAY..mw_evento e ON a.CodPeca=e.CodPeca AND e.id_base=212
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento AND a.CodApresentacao=ap.CodApresentacao
INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete apb ON ap.id_apresentacao=apb.id_apresentacao AND apb.in_ativo=1 AND apb.CodTipBilhete=1
where ls.CodApresentacao=4 and ls.StaCadeira='R' and ls.Indice in (select Indice from ciadeingressos..tabResCliente where CodCliente=19888)
AND ls.CodReserva='RJ64AOIHHH'


UPDATE ls
SET ls.StaCadeira='V'
    ,ls.CodTipBilhete=h.CodTipBilhete
    ,ls.CodVenda=h.codVenda
    -- ,ls.CodUsuario=@codUsuario
FROM tabLugSala ls 
INNER JOIN #helper h ON ls.CodApresentacao=h.codapresentacao AND ls.Indice=h.indice
WHERE ls.StaCadeira='R'

INSERT INTO tabLancamento (NumLancamento,CodTipBilhete,CodTipLancamento,CodApresentacao,Indice, 
CodUsuario,CodForPagto,CodCaixa,DatMovimento,QtdBilhete,ValPagto, DatVenda, CodMovimento)
    SELECT  
        h.numLancamento
        ,h.CodTipBilhete
        ,1
        ,h.CodApresentacao
        ,h.indice
        ,255
        ,54
        ,255
        ,'2019-03-31 09:18:00'
        ,1
        ,100
        ,'2019-03-31 09:18:00'
        ,NULL
FROM #helper h

INSERT INTO tabHisCliente (Codigo,NumLancamento,CodTipBilhete,CodTipLancamento,CodApresentacao,Indice)
    SELECT
    h.CodCliente
    ,h.numLancamento
    ,h.CodTipBilhete
    ,1
    ,h.codapresentacao
    ,h.indice
    FROM #helper h

-- INSERT INTO tabComprovante
-- 	(CodVenda,TipDocumento,NomSala,
-- 	Nome,Numero,DatValidade,
-- 	DDD,Telefone,Ramal,
--     CPF,RG,ForPagto,
-- 	NomUsuario,StaImpressao,NomEmpresa,
-- 	CodCliente,CodApresentacao,CodPeca)
-- SELECT TOP 1
--     h.codVenda,'V',h.NomSala
--     ,c.Nome,'',''
--     ,c.DDD,c.Telefone,c.Ramal
--     ,c.CPF,c.RG, h.CodTipBilhete
--     ,'WEB',0,'COMPREINGRESSOS.COM'
--     ,h.CodCliente,h.codapresentacao,h.CodPeca
-- FROM #helper h
-- INNER JOIN ciadeingressos..tabCliente c ON h.CodCliente=c.Codigo


INSERT INTO tabControleSeqVenda (codapresentacao, indice, numseq, codbar, statusingresso)
SELECT 
    h.codapresentacao
    ,h.indice
    ,1
    ,
right('00000'+convert(varchar,h.codapresentacao),5) --5
+convert(char(1), h.CodSetor) --6
+right('0000'+replace(convert(varchar(5),h.HorSessao),':',''),4) --10
+right('00000'+convert(varchar(10),h.indice),5) --15
+right('000000'+convert(varchar,h.number),6)
--+LEFT(CONVERT(VARCHAR(100),newid()),6) --21
    ,'L'
FROM #helper h


INSERT INTO tabIngresso	(Indice,CodVenda,NomObjeto
,NomPeca,NomRedPeca,DatApresentacao
,HorSessao,Elenco,Autor
,Diretor,NomRedSala,TipBilhete
,ValPagto,CodCaixa,[Login]
,NomResPeca,CenPeca,NomSetor
,DatVenda,Qtde,PerDesconto
,StaImpressao,CodSala,Id_Cartao_patrocinado
,BINCartao)
SELECT 
h.indice,h.codVenda
,SUBSTRING(h.NomObjeto,1,10)
,SUBSTRING(p.NomPeca,1,35),SUBSTRING(p.NomRedPeca,1,35),h.DatApresentacao
,SUBSTRING(h.HorSessao,1,5),SUBSTRING(p.Elenco,1,50),SUBSTRING(p.Autor,1,50)
,SUBSTRING(p.Diretor,1,50),SUBSTRING(h.NomRedSala,1,6),SUBSTRING('INTEIRA',1,20)
,h.valor,255,SUBSTRING('WEB', 0, 10)
,SUBSTRING(p.NomResPeca,0,6),p.CenPeca,SUBSTRING(h.NomSetor,1,26)
,GETDATE(), 1,0
,0,h.CodSala,(SELECT TOP 1 ep.id_cartao_patrocinado FROM CI_MIDDLEWAY..mw_evento_patrocinado ep WHERE ep.CodPeca=h.CodPeca AND ep.id_base=h.id_base AND convert(varchar, h.datapresentacao,112) between convert(varchar, ep.dt_inicio,112) and convert(varchar, ep.dt_fim ,112))-- ep.id_cartao_patrocinado
,''
FROM #helper h
INNER JOIN tabPeca p ON h.CodPeca=p.CodPeca




INSERT INTO CI_MIDDLEWAY..MW_ITEM_PEDIDO_VENDA (id_pedido_venda, id_reserva, ID_APRESENTACAO
                                                ,ID_APRESENTACAO_BILHETE,DS_LOCALIZACAO,DS_SETOR
                                                ,QT_INGRESSOS,VL_UNITARIO,VL_TAXA_CONVENIENCIA
                                                ,CODVENDA,INDICE, tickettype)
SELECT 
    h.id_pedido_venda, h.number, h.id_apresentacao
    , h.id_apresentacao_bilhete, h.NomObjeto, h.NomSetor
    , 1, h.VL_UNITARIO, h.VL_TAXA_CONVENIENCIA
    ,h.codVenda, h.Indice,h.ds_nome_site
FROM #helper h


-- CI_MIDDLEWAY..mw_reserva r
-- INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON r.id_apresentacao=ap.id_apresentacao
-- INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO_BILHETE AB ON AB.ID_APRESENTACAO = R.ID_APRESENTACAO AND AB.IN_ATIVO = 1 AND AB.ID_APRESENTACAO_BILHETE = R.ID_APRESENTACAO_BILHETE
-- INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento AND e.id_base=@id_base
-- INNER JOIN tabPeca p ON e.codPeca=p.CodPeca
-- INNER JOIN CI_MIDDLEWAY..current_session_client csc ON r.id_session=csc.id_session COLLATE SQL_Latin1_General_CP1_CI_AS
-- INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
-- INNER JOIN tabLugSala ls ON a.CodApresentacao=ls.CodApresentacao AND r.id_cadeira=ls.Indice
-- INNER JOIN tabSala s ON a.CodSala=s.CodSala
-- INNER JOIN tabSalDetalhe sd ON sd.Indice=ls.indice AND sd.CodSala=a.CodSala
-- INNER JOIN tabTipBilhete tb ON ab.CodTipBilhete=tb.CodTipBilhete
-- INNER JOIN tabSetor se ON sd.CodSetor=se.CodSetor AND a.CodSala=se.CodSala
-- WHERE csc.id_cliente=@id_cliente


