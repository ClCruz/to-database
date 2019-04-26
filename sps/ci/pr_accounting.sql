ALTER PROCEDURE dbo.pr_accounting (@id_evento INT
,@id_apresentacao INT = NULL
,@date DATETIME = NULL
,@hour VARCHAR(5) = NULL)

AS

-- DECLARE @id_evento INT = 32950
-- ,@id_apresentacao INT = NULL
-- ,@date DATETIME = '2019-04-13'
-- ,@hour VARCHAR(5) = '21h00'

-- INSERT INTO #ids (ID)
-- SELECT 167681
-- UNION ALL SELECT 167683
-- UNION ALL SELECT 167685

-- select * from CI_MIDDLEWAY..mw_apresentacao where id_apresentacao in (167681,167683,167685)
-- select * from tabApresentacao where CodApresentacao in (0,2,4)

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#ids', 'U') IS NOT NULL
    DROP TABLE #ids; 

IF OBJECT_ID('tempdb.dbo.#resultAux', 'U') IS NOT NULL
    DROP TABLE #resultAux; 

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

-- SELECT @nameResp=p.ds_razao_social
--         ,@documentResp=p.cd_cpf_cnpj
--         ,@addressResp=p.ds_endereco
-- FROM CI_MIDDLEWAY..mw_produtor p
-- WHERE p.id_produtor=@id_produtor

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
FROM CI_MIDDLEWAY..mw_apresentacao ap
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
INNER JOIN tabPeca p ON e.CodPeca=p.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_produtor pr ON p.id_produtor=pr.id_produtor
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..mw_local_evento le ON e.id_local_evento=le.id_local_evento
WHERE ap.id_apresentacao IN (SELECT ID FROM #ids)

DECLARE @seats INT = NULL
        ,@seats_taken_web INT = NULL
        ,@seats_taken_ticketoffice INT = NULL
        ,@seats_inprocess INT = NULL
        ,@seats_reserved INT = NULL
        ,@seats_available INT = NULL
        ,@seats_taken_web_paid INT = NULL
        ,@seats_taken_ticketoffice_paid INT = NULL
        ,@seats_taken_web_free INT = NULL
        ,@seats_taken_ticketoffice_free INT = NULL


SELECT @seats=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
-- LEFT JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO='C'

SELECT @seats_taken_web=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
INNER JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.id_apresentacao=ap.id_apresentacao AND ipv.Indice=s.Indice AND ipv.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda
WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO='C' AND pv.in_situacao='F' AND ls.StaCadeira='V'

SELECT @seats_taken_ticketoffice=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
INNER JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
INNER JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosc ON tosc.id_apresentacao=ap.id_apresentacao AND tosc.Indice=s.Indice AND tosc.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO='C' AND ls.StaCadeira='V'

SELECT @seats_inprocess=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
INNER JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.id_apresentacao=ap.id_apresentacao AND ipv.Indice=s.Indice AND ipv.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda
WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO='C' AND pv.in_situacao='P' AND ls.StaCadeira='V'


SELECT @seats_reserved=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
INNER JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO='C' AND ls.StaCadeira='R'

SELECT @seats_available=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
LEFT JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO='C' AND ls.StaCadeira IS NULL

SELECT @seats_taken_web_paid=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
INNER JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.id_apresentacao=ap.id_apresentacao AND ipv.Indice=s.Indice AND ipv.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete apb ON ipv.id_apresentacao_bilhete=apb.id_apresentacao_bilhete --AND apb.id_apresentacao=ap.id_apresentacao
INNER JOIN tabTipBilhete tb ON apb.CodTipBilhete=tb.CodTipBilhete
WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO='C' AND pv.in_situacao='F' AND ls.StaCadeira='V' AND (tb.PerDesconto!=100)


SELECT @seats_taken_web_free=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
INNER JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.id_apresentacao=ap.id_apresentacao AND ipv.Indice=s.Indice AND ipv.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete apb ON ipv.id_apresentacao_bilhete=apb.id_apresentacao_bilhete --AND apb.id_apresentacao=ap.id_apresentacao
INNER JOIN tabTipBilhete tb ON apb.CodTipBilhete=tb.CodTipBilhete
WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO='C' AND pv.in_situacao='F' AND ls.StaCadeira='V' AND (tb.PerDesconto=100)

SELECT @seats_taken_ticketoffice_paid=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
INNER JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
INNER JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosc ON tosc.id_apresentacao=ap.id_apresentacao AND tosc.Indice=s.Indice AND tosc.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN tabTipBilhete tb ON tosc.id_ticket_type=tb.CodTipBilhete
WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO='C' AND ls.StaCadeira='V' AND (tb.PerDesconto!=100)

SELECT @seats_taken_ticketoffice_free=COUNT(*)
FROM tabSalDetalhe S
INNER JOIN tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN tabApresentacao A ON A.CODSALA = S.CODSALA
INNER JOIN tabPeca P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
INNER JOIN tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO
INNER JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosc ON tosc.id_apresentacao=ap.id_apresentacao AND tosc.Indice=s.Indice AND tosc.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN tabTipBilhete tb ON tosc.id_ticket_type=tb.CodTipBilhete
WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO='C' AND ls.StaCadeira='V' AND (tb.PerDesconto=100)

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

SELECT @result_all = @seats
, @result_notsold = (@seats_available+@seats_reserved+@seats_inprocess)
, @result_free = (@seats_taken_ticketoffice_free+@seats_taken_web_free)
, @result_paid = (@seats_taken_ticketoffice_paid+@seats_taken_web_paid)
, @result_paid_and_free = (@seats_taken_ticketoffice_free+@seats_taken_web_free)+(@seats_taken_ticketoffice_paid+@seats_taken_web_paid)


-- select top 1 * from tabLancamento
SELECT
        l.Indice
        ,l.CodTipBilhete
        ,a.CodSala
        ,se.CodSetor
        ,s.NomSala
        ,se.NomSetor
        ,tb.TipBilhete
        ,l.CodTipLancamento
        ,CONVERT(BIGINT,ABS(l.ValPagto)*100) ValPagto
        --,ABS(l.ValPagto)*100 ValPagto
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
WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND sd.TipObjeto='C'-- AND ls.StaCadeira='V'


SELECT 
        ra.CodSala
        ,ra.NomSala
        ,ra.CodSetor
        ,ra.NomSetor
        ,ra.CodTipBilhete
        ,ra.TipBilhete
        ,ra.ValPagto
        ,(SELECT COUNT(*) FROM #resultAux sub WHERE sub.CodSala=ra.CodSala AND sub.CodSetor=ra.CodSetor AND sub.CodTipBilhete=ra.CodTipBilhete AND sub.CodTipLancamento=1 AND sub.ValPagto=ra.ValPagto) sold
        ,(SELECT SUM(sub.ValPagto) FROM #resultAux sub WHERE sub.CodSala=ra.CodSala AND sub.CodSetor=ra.CodSetor AND sub.CodTipBilhete=ra.CodTipBilhete AND sub.CodTipLancamento=1 AND sub.ValPagto=ra.ValPagto) soldamount
        ,(SELECT SUM(sub.ValPagto) FROM #resultAux sub WHERE sub.CodSala=ra.CodSala AND sub.CodSetor=ra.CodSetor AND sub.CodTipBilhete=ra.CodTipBilhete AND sub.CodTipLancamento=2 AND sub.ValPagto=ra.ValPagto) refundamount
        ,(SELECT COUNT(*) FROM #resultAux sub WHERE sub.CodSala=ra.CodSala AND sub.CodSetor=ra.CodSetor AND sub.CodTipBilhete=ra.CodTipBilhete AND sub.CodTipLancamento=2 AND sub.ValPagto=ra.ValPagto) refund
INTO #resultFinal
FROM #resultAux ra
GROUP BY ra.CodSala, ra.NomSala,ra.CodSetor,ra.NomSetor,ra.CodTipBilhete,ra.TipBilhete,ra.ValPagto
ORDER BY ra.TipBilhete, ra.NomSetor


SELECT @result_all = @seats
, @result_notsold = (@seats_available+@seats_reserved+@seats_inprocess)
, @result_free = (@seats_taken_ticketoffice_free+@seats_taken_web_free)
, @result_paid = (@seats_taken_ticketoffice_paid+@seats_taken_web_paid)
, @result_paid_and_free = (@seats_taken_ticketoffice_free+@seats_taken_web_free)+(@seats_taken_ticketoffice_paid+@seats_taken_web_paid)

SELECT
        @local [local]
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
        ,rf.NomSetor
        ,rf.TipBilhete
        ,(rf.sold-rf.refund) sold
        -- ,rf.sold soldt
        ,rf.refund
        ,rf.ValPagto
        ,(rf.soldamount-rf.refundamount) soldamount
        -- ,rf.soldamount soldamountt
FROM #resultFinal rf
ORDER BY rf.TipBilhete, rf.NomSetor