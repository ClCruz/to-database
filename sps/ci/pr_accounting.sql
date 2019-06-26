-- -- exec pr_accounting 'a705cc76-9078-4cb4-849e-0e6b31adeb52'
-- -- exec pr_accounting_debits 'a705cc76-9078-4cb4-849e-0e6b31adeb52'

ALTER PROCEDURE dbo.pr_accounting (@id VARCHAR(100))

AS
-- DECLARE @id VARCHAR(100) = '78F4934C-1B8F-4A74-BE39-83CB7601A7FC'

SET NOCOUNT ON;

DECLARE @id_evento INT = NULL
        ,@id_apresentacao INT = NULL
        ,@date DATETIME = NULL
        ,@hour VARCHAR(5) = NULL
        ,@used BIT = 0

SELECT 
@id_evento=ak.id_evento
,@id_apresentacao=ak.id_apresentacao
,@date=ak.[date]
,@hour=ak.hour
,@used=ak.used
FROM CI_MIDDLEWAY..accounting_key ak
WHERE ak.id=@id

DECLARE @weekday TABLE (id INT, [name] VARCHAR(100), [full] VARCHAR(100));

INSERT INTO @weekday (id, [name],[full]) VALUES(1, 'dom', 'domingo')
INSERT INTO @weekday (id, [name],[full]) VALUES(2, 'seg', 'segunda-feira')
INSERT INTO @weekday (id, [name],[full]) VALUES(3, 'ter', 'terça-feira')
INSERT INTO @weekday (id, [name],[full]) VALUES(4, 'qua', 'quarta-feira')
INSERT INTO @weekday (id, [name],[full]) VALUES(5, 'qui', 'quinta-feira')
INSERT INTO @weekday (id, [name],[full]) VALUES(6, 'sex', 'sexta-feira')
INSERT INTO @weekday (id, [name],[full]) VALUES(7, 'sab', 'sábado')

IF OBJECT_ID('tempdb.dbo.#ids', 'U') IS NOT NULL
    DROP TABLE #ids; 

IF OBJECT_ID('tempdb.dbo.#resultAux', 'U') IS NOT NULL
    DROP TABLE #resultAux; 

IF OBJECT_ID('tempdb.dbo.#resultToCount', 'U') IS NOT NULL
    DROP TABLE #resultToCount; 

IF OBJECT_ID('tempdb.dbo.#resultFinal', 'U') IS NOT NULL
    DROP TABLE #resultFinal; 


CREATE TABLE #ids (ID INT)

IF @id_apresentacao IS NULL
BEGIN
        INSERT INTO #ids (id)
        SELECT ap.id_apresentacao
        FROM CI_MIDDLEWAY..mw_apresentacao ap
        WHERE ap.id_evento=@id_evento
        AND ap.dt_apresentacao=@date
        AND ap.hr_apresentacao=@hour
END
ELSE
BEGIN
        INSERT INTO #ids (id)
        SELECT @id_apresentacao
END


DECLARE @local VARCHAR(1000)
        ,@event VARCHAR(1000)
        ,@responsible VARCHAR(1000)
        ,@responsibleDoc VARCHAR(1000)
        ,@responsibleAddress VARCHAR(1000)
        ,@number VARCHAR(100)
        ,@presentation_number VARCHAR(100)
        ,@presentation_date VARCHAR(100)
        ,@presentation_hour VARCHAR(100)
        ,@sector VARCHAR(1000)
        ,@weekdayname VARCHAR(100)
        ,@weekdayfull VARCHAR(100)

SELECT
        @local=le.ds_local_evento
        ,@event=e.ds_evento
        ,@responsible=pr.ds_razao_social
        ,@responsibleDoc=pr.cd_cpf_cnpj
        ,@responsibleAddress=pr.ds_endereco
        ,@number=a.NumBordero
        ,@presentation_number=a.NumBordero
        ,@presentation_date=CONVERT(VARCHAR(10),ap.dt_apresentacao,103)
        ,@presentation_hour=ap.hr_apresentacao
        ,@sector=(CASE WHEN @id_apresentacao IS NULL THEN 'Todos' ELSE ap.ds_piso END)
        ,@weekdayname=(SELECT TOP 1 [name] FROM @weekday WHERE id = DATEPART(dw, a.DatApresentacao))
        ,@weekdayfull=(SELECT TOP 1 [full] FROM @weekday WHERE id = DATEPART(dw, a.DatApresentacao))

FROM CI_MIDDLEWAY..mw_apresentacao ap
INNER JOIN #ids i ON ap.id_apresentacao=i.ID 
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
INNER JOIN tabPeca p ON e.CodPeca=p.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_produtor pr ON p.id_produtor=pr.id_produtor
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..mw_local_evento le ON e.id_local_evento=le.id_local_evento

DECLARE @seats INT = 0
        ,@seats_taken_web INT = 0
        ,@seats_taken_ticketoffice INT = 0
        ,@seats_inprocess INT = 0
        ,@seats_reserved INT = 0
        ,@seats_available INT = 0
        ,@seats_taken_web_paid INT = 0
        ,@seats_taken_ticketoffice_paid INT = 0
        ,@seats_taken_web_free INT = 0
        ,@seats_taken_ticketoffice_free INT = 0


SELECT @seats=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
INNER JOIN #ids i ON ap.id_apresentacao=i.ID 
WHERE S.TIPOBJETO='C'

SELECT @seats_taken_web=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
INNER JOIN #ids i ON ap.id_apresentacao=i.ID 
INNER JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.id_apresentacao=ap.id_apresentacao AND ipv.Indice=s.Indice AND ipv.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda
WHERE S.TIPOBJETO='C' AND pv.in_situacao='F' AND ls.StaCadeira='V'

SELECT @seats_taken_ticketoffice=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
INNER JOIN #ids i ON ap.id_apresentacao=i.ID 
INNER JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
INNER JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosc ON tosc.id_apresentacao=ap.id_apresentacao AND tosc.Indice=s.Indice AND tosc.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE S.TIPOBJETO='C' AND ls.StaCadeira='V'

SELECT @seats_inprocess=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
INNER JOIN #ids i ON ap.id_apresentacao=i.ID 
INNER JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.id_apresentacao=ap.id_apresentacao AND ipv.Indice=s.Indice AND ipv.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda
WHERE S.TIPOBJETO='C' AND pv.in_situacao='P' AND ls.StaCadeira='V'


SELECT @seats_reserved=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
INNER JOIN #ids i ON ap.id_apresentacao=i.ID 
INNER JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
WHERE S.TIPOBJETO='C' AND ls.StaCadeira='R'

SELECT @seats_available=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
INNER JOIN #ids i ON ap.id_apresentacao=i.ID 
LEFT JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
WHERE S.TIPOBJETO='C' AND ls.StaCadeira IS NULL

SELECT @seats_taken_web_paid=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
INNER JOIN #ids i ON ap.id_apresentacao=i.ID 
INNER JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.id_apresentacao=ap.id_apresentacao AND ipv.Indice=s.Indice AND ipv.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete apb ON ipv.id_apresentacao_bilhete=apb.id_apresentacao_bilhete
INNER JOIN tabTipBilhete tb ON apb.CodTipBilhete=tb.CodTipBilhete
WHERE S.TIPOBJETO='C' AND pv.in_situacao='F' AND ls.StaCadeira='V' AND (tb.PerDesconto!=100)


SELECT @seats_taken_web_free=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
INNER JOIN #ids i ON ap.id_apresentacao=i.ID 
INNER JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.id_apresentacao=ap.id_apresentacao AND ipv.Indice=s.Indice AND ipv.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete apb ON ipv.id_apresentacao_bilhete=apb.id_apresentacao_bilhete
INNER JOIN tabTipBilhete tb ON apb.CodTipBilhete=tb.CodTipBilhete
WHERE S.TIPOBJETO='C' AND pv.in_situacao='F' AND ls.StaCadeira='V' AND (tb.PerDesconto=100)

SELECT @seats_taken_ticketoffice_paid=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
INNER JOIN #ids i ON ap.id_apresentacao=i.ID 
INNER JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
INNER JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosc ON tosc.id_apresentacao=ap.id_apresentacao AND tosc.Indice=s.Indice AND tosc.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN tabTipBilhete tb ON tosc.id_ticket_type=tb.CodTipBilhete
WHERE S.TIPOBJETO='C' AND ls.StaCadeira='V' AND (tb.PerDesconto!=100)

SELECT @seats_taken_ticketoffice_free=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
INNER JOIN #ids i ON ap.id_apresentacao=i.ID 
INNER JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
INNER JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosc ON tosc.id_apresentacao=ap.id_apresentacao AND tosc.Indice=s.Indice AND tosc.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN tabTipBilhete tb ON tosc.id_ticket_type=tb.CodTipBilhete
WHERE S.TIPOBJETO='C' AND ls.StaCadeira='V' AND (tb.PerDesconto=100)

-- SELECT @seats seats
--         ,@seats_taken_web seats_taken_web
--         ,@seats_taken_ticketoffice seats_taken_ticketoffice
--         ,@seats_inprocess seats_inprocess
--         ,@seats_reserved seats_reserved
--         ,@seats_available seats_available
--         ,@seats_taken_web_paid seats_taken_web_paid
--         ,@seats_taken_ticketoffice_paid seats_taken_ticketoffice_paid
--         ,@seats_taken_web_free seats_taken_web_free
--         ,@seats_taken_ticketoffice_free seats_taken_ticketoffice_free

-- return;

DECLARE @result_all INT
        ,@result_notsold INT
        ,@result_paid INT
        ,@result_free INT
        ,@result_paid_and_free INT
        ,@result_occupancyrate DECIMAL(12,2)
        

SELECT @result_all = @seats
, @result_notsold = (@seats-(@seats_taken_web+@seats_taken_ticketoffice))
, @result_free = (@seats_taken_ticketoffice_free+@seats_taken_web_free)
, @result_paid = (@seats_taken_ticketoffice_paid+@seats_taken_web_paid)
, @result_paid_and_free = (@seats_taken_ticketoffice_free+@seats_taken_web_free)+(@seats_taken_ticketoffice_paid+@seats_taken_web_paid)
, @result_occupancyrate = ROUND(CONVERT(DECIMAL(18,2),@result_paid_and_free)/CONVERT(DECIMAL(18,2),@result_all)*100,2)

SELECT DISTINCT
        l.Indice
        ,l.CodTipBilhete
        ,a.CodSala
        ,se.CodSetor
        ,s.NomSala
        ,se.NomSetor
        ,tb.TipBilhete
        ,l.CodTipLancamento
        ,CONVERT(BIGINT,ABS(l.ValPagto)*100) ValPagto
        ,(CASE WHEN pv.id_pedido_venda IS NOT NULL AND pv.in_situacao='P' THEN 1 ELSE 0 END) inprocess
        ,(CASE WHEN ls.Indice IS NOT NULL AND ls.StaCadeira='V' THEN 1 ELSE 0 END) isok
INTO #resultAux
FROM tabLancamento l
INNER JOIN tabTipBilhete tb ON l.CodTipBilhete=tb.CodTipBilhete
INNER JOIN tabApresentacao a ON l.CodApresentacao=a.CodApresentacao
INNER JOIN tabPeca p ON a.CodPeca=p.CodPeca
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN tabSetor se ON se.CodSala=a.CodSala
INNER JOIN tabSalDetalhe sd ON sd.Indice=l.Indice AND sd.CodSala=a.CodSala AND sd.CodSetor=se.CodSetor
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento AND ap.CodApresentacao=a.CodApresentacao
INNER JOIN #ids i ON ap.id_apresentacao=i.ID 
LEFT JOIN tabLugSala ls ON ls.INDICE = l.indice AND ls.CODAPRESENTACAO = l.CODAPRESENTACAO AND ls.CodTipBilhete=l.CodTipBilhete
LEFT JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.id_apresentacao=ap.id_apresentacao AND ipv.Indice=l.Indice AND ipv.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS
LEFT JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda
WHERE sd.TipObjeto='C'

SELECT 
        ra.CodSala
        ,ra.NomSala
        ,ra.CodSetor
        ,ra.NomSetor
        ,ra.CodTipBilhete
        ,ra.TipBilhete
        ,ra.ValPagto
        ,ISNULL((SELECT COUNT(*) FROM #resultAux sub WHERE sub.CodSala=ra.CodSala AND sub.CodSetor=ra.CodSetor AND sub.CodTipBilhete=ra.CodTipBilhete AND sub.CodTipLancamento=1 AND sub.ValPagto=ra.ValPagto AND sub.isok=1),0) sold
        ,ISNULL((SELECT SUM(sub.ValPagto) FROM #resultAux sub WHERE sub.CodSala=ra.CodSala AND sub.CodSetor=ra.CodSetor AND sub.CodTipBilhete=ra.CodTipBilhete AND sub.CodTipLancamento=1 AND sub.ValPagto=ra.ValPagto AND sub.isok=1),0) soldamount
        ,ISNULL((SELECT SUM(sub.ValPagto) FROM #resultAux sub WHERE sub.CodSala=ra.CodSala AND sub.CodSetor=ra.CodSetor AND sub.CodTipBilhete=ra.CodTipBilhete AND sub.CodTipLancamento=2 AND sub.ValPagto=ra.ValPagto),0) refundamount
        ,ISNULL((SELECT COUNT(*) FROM #resultAux sub WHERE sub.CodSala=ra.CodSala AND sub.CodSetor=ra.CodSetor AND sub.CodTipBilhete=ra.CodTipBilhete AND sub.CodTipLancamento=2 AND sub.ValPagto=ra.ValPagto),0) refund
INTO #resultToCount
FROM #resultAux ra
GROUP BY ra.CodSala, ra.NomSala,ra.CodSetor,ra.NomSetor,ra.CodTipBilhete,ra.TipBilhete,ra.ValPagto
ORDER BY ra.TipBilhete, ra.NomSetor

-- SELECT @result_all = @seats
-- , @result_notsold = (@seats_available+@seats_reserved+@seats_inprocess)
-- , @result_free = (@seats_taken_ticketoffice_free+@seats_taken_web_free)
-- , @result_paid = (@seats_taken_ticketoffice_paid+@seats_taken_web_paid)
-- , @result_paid_and_free = (@seats_taken_ticketoffice_free+@seats_taken_web_free)+(@seats_taken_ticketoffice_paid+@seats_taken_web_paid)

SELECT
        @local [local]
        ,@weekdayname weekdayname
        ,@weekdayfull weekdayfull
        ,@event [event]
        ,@responsible [responsible]
        ,@responsibleDoc responsibleDoc
        ,@responsibleAddress responsibleAddress
        ,@number [number]
        ,@presentation_number [presentation_number]
        ,@presentation_date [presentation_date]
        ,@presentation_hour [presentation_hour]
        ,@sector [sector]
        ,@result_all totalizer_all
        ,@result_notsold totalizer_notsold
        ,@result_free totalizer_free
        ,@result_paid totalizer_paid
        ,@result_paid_and_free totalizer_paid_and_free
        ,rf.CodSala
        ,rf.CodSetor
        ,rf.CodTipBilhete
        ,rf.NomSetor
        ,rf.TipBilhete
        ,(rf.sold) sold
        -- ,(rf.sold-rf.refund) sold
        -- ,rf.sold soldt
        ,rf.refund
        ,rf.ValPagto
        ,FORMAT(CONVERT(DECIMAL(12,2),rf.ValPagto)/100, 'N', 'pt-br') ValPagtoformatted
        ,(rf.soldamount) soldamount
        -- ,(rf.soldamount-rf.refundamount) soldamount
        ,FORMAT(CONVERT(DECIMAL(12,2),(rf.soldamount)/100), 'N', 'pt-br') soldamountformatted
        -- ,FORMAT(CONVERT(DECIMAL(12,2),(rf.soldamount-rf.refundamount)/100), 'N', 'pt-br') soldamountformatted
        ,@result_occupancyrate occupancyrate
        -- ,rf.soldamount soldamountt
INTO #resultFinal
FROM #resultToCount rf
ORDER BY rf.TipBilhete, rf.NomSetor

SELECT
        @local [local]
        ,@weekdayname weekdayname
        ,@weekdayfull weekdayfull
        ,@event [event]
        ,@responsible [responsible]
        ,@responsibleDoc responsibleDoc
        ,@responsibleAddress responsibleAddress
        ,@number [number]
        ,@presentation_number [presentation_number]
        ,@presentation_date [presentation_date]
        ,@presentation_hour [presentation_hour]
        ,@sector [sector]
        ,@result_all totalizer_all
        ,@result_notsold totalizer_notsold
        ,@result_free totalizer_free
        ,@result_paid totalizer_paid
        ,@result_paid_and_free totalizer_paid_and_free
        ,rf.CodSala
        ,rf.CodTipBilhete
        ,rf.NomSetor
        ,rf.TipBilhete
        ,rf.sold
        -- ,rf.sold soldt
        ,rf.refund
        ,rf.ValPagto
        ,rf.ValPagtoformatted
        ,rf.soldamount
        ,rf.soldamountformatted
        ,rf.occupancyrate
        ,(SELECT SUM(sub.refund) FROM #resultFinal sub) total_refund
        ,(SELECT SUM(sub.sold) FROM #resultFinal sub) total_sold
        ,(SELECT SUM(sub.soldamount) FROM #resultFinal sub) total_soldamount
        ,FORMAT(CONVERT(DECIMAL(12,2),(SELECT SUM(sub.soldamount) FROM #resultFinal sub)/100), 'N', 'pt-br') total_soldamountformatted
        ,CONVERT(VARCHAR(10),GETDATE(),103) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114) [date]
        -- ,rf.soldamount soldamountt
FROM #resultFinal rf
ORDER BY rf.TipBilhete, rf.NomSetor