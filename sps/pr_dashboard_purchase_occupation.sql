CREATE PROCEDURE dbo.pr_dashboard_purchase_occupation (@id_evento INT
        ,@id_apresentacao INT
        ,@date DATETIME
        ,@hour VARCHAR(5))

AS

-- -- exec pr_accounting 'a705cc76-9078-4cb4-849e-0e6b31adeb52'
-- -- exec pr_accounting_debits 'a705cc76-9078-4cb4-849e-0e6b31adeb52'
-- select top 1 * from CI_MIDDLEWAY..accounting_key order by created desc

-- DECLARE @id_evento INT = 43864
--         ,@id_apresentacao INT = NULL
--         ,@date DATETIME = '2019-07-12'
--         ,@hour VARCHAR(5) = '20h00'
--         ,@periodtype VARCHAR(100) = 'all' --- all, thirty, fifteen, seven, yesterday, today, custom
--         ,@periodInit DATETIME = NULL
--         ,@periodEnd DATETIME = NULL


IF @id_apresentacao = 0
    SET @id_apresentacao = NULL

IF @id_apresentacao = 0
    SET @id_apresentacao = NULL

IF @id_apresentacao = 0
    SET @id_apresentacao = NULL

SET NOCOUNT ON;


IF OBJECT_ID('tempdb.dbo.#ids', 'U') IS NOT NULL
    DROP TABLE #ids; 

IF OBJECT_ID('tempdb.dbo.#result', 'U') IS NOT NULL
    DROP TABLE #result; 

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


DECLARE @id_base INT

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_evento WHERE id_evento=@id_evento

DECLARE @db_name VARCHAR(1000),@toExec NVARCHAR(MAX)

SELECT TOP 1 @db_name=b.ds_nome_base_sql FROM CI_MIDDLEWAY..mw_base b WHERE b.id_base=@id_base;

SET @toExec=''
SET @toExec = @toExec + ' SELECT @seats=COUNT(*) '
SET @toExec = @toExec + ' FROM '+@db_name+'.dbo.tabSalDetalhe S '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabApresentacao A ON A.CODSALA = S.CODSALA '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabPeca P ON P.CODPECA = A.CODPECA '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento '
SET @toExec = @toExec + ' WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO=''C'' '
EXEC sp_executesql @toExec, N'@seats INT OUTPUT', @seats OUTPUT

SET @toExec=''
SET @toExec = @toExec + ' SELECT @seats_taken_web=COUNT(*) '
SET @toExec = @toExec + ' FROM '+@db_name+'.dbo.tabSalDetalhe S '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabApresentacao A ON A.CODSALA = S.CODSALA '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabPeca P ON P.CODPECA = A.CODPECA '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.id_apresentacao=ap.id_apresentacao AND ipv.Indice=s.Indice AND ipv.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda '
SET @toExec = @toExec + ' WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO=''C'' AND pv.in_situacao=''F'' AND ls.StaCadeira=''V'' '
EXEC sp_executesql @toExec, N'@seats_taken_web INT OUTPUT', @seats_taken_web OUTPUT

SET @toExec=''
SET @toExec = @toExec + ' SELECT @seats_taken_ticketoffice=COUNT(*) '
SET @toExec = @toExec + ' FROM '+@db_name+'.dbo.tabSalDetalhe S '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabApresentacao A ON A.CODSALA = S.CODSALA '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabPeca P ON P.CODPECA = A.CODPECA '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosc ON tosc.id_apresentacao=ap.id_apresentacao AND tosc.Indice=s.Indice AND tosc.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS '
SET @toExec = @toExec + ' WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO=''C'' AND ls.StaCadeira=''V'' '
EXEC sp_executesql @toExec, N'@seats_taken_ticketoffice INT OUTPUT', @seats_taken_ticketoffice OUTPUT

SET @toExec=''
SET @toExec = @toExec + ' SELECT @seats_inprocess=COUNT(*) '
SET @toExec = @toExec + ' FROM '+@db_name+'.dbo.tabSalDetalhe S '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabApresentacao A ON A.CODSALA = S.CODSALA '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabPeca P ON P.CODPECA = A.CODPECA '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.id_apresentacao=ap.id_apresentacao AND ipv.Indice=s.Indice AND ipv.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda '
SET @toExec = @toExec + ' WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO=''C'' AND pv.in_situacao=''P'' AND ls.StaCadeira=''V'' '
EXEC sp_executesql @toExec, N'@seats_inprocess INT OUTPUT', @seats_inprocess OUTPUT


SET @toExec=''
SET @toExec = @toExec + ' SELECT @seats_reserved=COUNT(*) '
SET @toExec = @toExec + ' FROM '+@db_name+'.dbo.tabSalDetalhe S '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabApresentacao A ON A.CODSALA = S.CODSALA '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabPeca P ON P.CODPECA = A.CODPECA '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO '
SET @toExec = @toExec + ' WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO=''C'' AND ls.StaCadeira=''R'' '
EXEC sp_executesql @toExec, N'@seats_reserved INT OUTPUT', @seats_reserved OUTPUT

SET @toExec=''
SET @toExec = @toExec + ' SELECT @seats_available=COUNT(*) '
SET @toExec = @toExec + ' FROM '+@db_name+'.dbo.tabSalDetalhe S '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabApresentacao A ON A.CODSALA = S.CODSALA '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabPeca P ON P.CODPECA = A.CODPECA '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento '
SET @toExec = @toExec + ' LEFT JOIN '+@db_name+'.dbo.tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO '
SET @toExec = @toExec + ' WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO=''C'' AND ls.StaCadeira IS NULL '
EXEC sp_executesql @toExec, N'@seats_available INT OUTPUT', @seats_available OUTPUT

SET @toExec=''
SET @toExec = @toExec + ' SELECT @seats_taken_web_paid=COUNT(*) '
SET @toExec = @toExec + ' FROM '+@db_name+'.dbo.tabSalDetalhe S '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabApresentacao A ON A.CODSALA = S.CODSALA '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabPeca P ON P.CODPECA = A.CODPECA '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.id_apresentacao=ap.id_apresentacao AND ipv.Indice=s.Indice AND ipv.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete apb ON ipv.id_apresentacao_bilhete=apb.id_apresentacao_bilhete '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabTipBilhete tb ON apb.CodTipBilhete=tb.CodTipBilhete '
SET @toExec = @toExec + ' WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO=''C'' AND pv.in_situacao=''F'' AND ls.StaCadeira=''V'' AND (tb.PerDesconto!=100) '
EXEC sp_executesql @toExec, N'@seats_taken_web_paid INT OUTPUT', @seats_taken_web_paid OUTPUT

SET @toExec=''
SET @toExec = @toExec + ' SELECT @seats_taken_web_free=COUNT(*) '
SET @toExec = @toExec + ' FROM '+@db_name+'.dbo.tabSalDetalhe S '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabApresentacao A ON A.CODSALA = S.CODSALA '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabPeca P ON P.CODPECA = A.CODPECA '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.id_apresentacao=ap.id_apresentacao AND ipv.Indice=s.Indice AND ipv.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete apb ON ipv.id_apresentacao_bilhete=apb.id_apresentacao_bilhete '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabTipBilhete tb ON apb.CodTipBilhete=tb.CodTipBilhete '
SET @toExec = @toExec + ' WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO=''C'' AND pv.in_situacao=''F'' AND ls.StaCadeira=''V'' AND (tb.PerDesconto=100) '
EXEC sp_executesql @toExec, N'@seats_taken_web_free INT OUTPUT', @seats_taken_web_free OUTPUT

SET @toExec=''
SET @toExec = @toExec + ' SELECT @seats_taken_ticketoffice_paid=COUNT(*) '
SET @toExec = @toExec + ' FROM '+@db_name+'.dbo.tabSalDetalhe S '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabApresentacao A ON A.CODSALA = S.CODSALA '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabPeca P ON P.CODPECA = A.CODPECA '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosc ON tosc.id_apresentacao=ap.id_apresentacao AND tosc.Indice=s.Indice AND tosc.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabTipBilhete tb ON tosc.id_ticket_type=tb.CodTipBilhete '
SET @toExec = @toExec + ' WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO=''C'' AND ls.StaCadeira=''V'' AND (tb.PerDesconto!=100) '
EXEC sp_executesql @toExec, N'@seats_taken_ticketoffice_paid INT OUTPUT', @seats_taken_ticketoffice_paid OUTPUT

SET @toExec=''
SET @toExec = @toExec + ' SELECT @seats_taken_ticketoffice_free=COUNT(*) '
SET @toExec = @toExec + ' FROM '+@db_name+'.dbo.tabSalDetalhe S '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSetor SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabApresentacao A ON A.CODSALA = S.CODSALA '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabPeca P ON P.CODPECA = A.CODPECA '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabLugSala ls ON ls.INDICE = S.INDICE AND ls.CODAPRESENTACAO = A.CODAPRESENTACAO '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosc ON tosc.id_apresentacao=ap.id_apresentacao AND tosc.Indice=s.Indice AND tosc.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabTipBilhete tb ON tosc.id_ticket_type=tb.CodTipBilhete '
SET @toExec = @toExec + ' WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND S.TIPOBJETO=''C'' AND ls.StaCadeira=''V'' AND (tb.PerDesconto=100) '
EXEC sp_executesql @toExec, N'@seats_taken_ticketoffice_free INT OUTPUT', @seats_taken_ticketoffice_free OUTPUT

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
        ,@result_waiting_payment INT
        ,@result_free INT
        ,@result_reserved INT
        ,@result_paid_and_free INT
        ,@result_occupancyrate DECIMAL(12,2)


SET @result_all = @seats;
SET @result_free = (@seats_taken_ticketoffice_free+@seats_taken_web_free);
SET @result_paid = (@seats_taken_ticketoffice_paid+@seats_taken_web_paid);
SET @result_waiting_payment = @seats_inprocess;
SET @result_reserved = @seats_reserved;
SET @result_paid_and_free = (@seats_taken_ticketoffice_free+@seats_taken_web_free)+(@seats_taken_ticketoffice_paid+@seats_taken_web_paid);
SET @result_notsold = (@seats-(@result_paid_and_free+@result_waiting_payment+@result_reserved))

SELECT-- @result_notsold = (@seats-(@seats_taken_web+@seats_taken_ticketoffice+@seats_inprocess+@seats_reserved))
--, 
@result_occupancyrate = ROUND(CONVERT(DECIMAL(18,2),@result_paid_and_free)/CONVERT(DECIMAL(18,2),@result_all)*100,2)

SELECT @result_all result_all
        ,@result_notsold result_notsold
        ,@result_free result_free
        ,@result_paid result_paid
        ,@result_waiting_payment result_waiting_payment
        ,@result_reserved result_reserved
        ,@result_paid_and_free result_paid_and_free
        ,@result_occupancyrate result_occupancyrate
        ,FORMAT(CONVERT(DECIMAL(12,2),(@result_occupancyrate)), 'N', 'pt-br') result_occupancyrateformatted
