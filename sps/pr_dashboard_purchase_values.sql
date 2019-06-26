-- exec sp_executesql N'EXEC pr_dashboard_purchase_values @P1,@P2,@P3,@P4,@P5,@P6,@P7',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000),@P7 nvarchar(4000)',N'33113',N'',N'2019-06-30',N'18h00',N'today',N'',N''
-- exec sp_executesql N'EXEC pr_dashboard_purchase_values @P1,@P2,@P3,@P4,@P5,@P6,@P7',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000),@P7 nvarchar(4000)',N'43864',N'',N'2019-07-12',N'20h00',N'all',N'',N''
-- exec sp_executesql N'EXEC pr_dashboard_purchase_values @P1,@P2,@P3,@P4,@P5,@P6,@P7',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000),@P7 nvarchar(4000)',N'43864',N'',N'2019-07-12',N'20h00',N'all',N'',N''
--exec sp_executesql N'EXEC pr_dashboard_purchase_values @P1,@P2,@P3,@P4,@P5,@P6,@P7',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000),@P7 nvarchar(4000)',N'43864',N'',N'2019-07-12',N'20h00',N'seven',N'',N''
---exec sp_executesql N'EXEC pr_dashboard_purchase_values @P1,@P2,@P3,@P4,@P5,@P6,@P7',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000),@P7 nvarchar(4000)',N'32955',N'',N'2019-06-28',N'21h00',N'today',N'',N''

ALTER PROCEDURE dbo.pr_dashboard_purchase_values (@id_evento INT
        ,@id_apresentacao INT
        ,@date DATETIME
        ,@hour VARCHAR(5)
        ,@periodtype VARCHAR(100)
        ,@periodInit DATETIME
        ,@periodEnd DATETIME)

AS

-- DECLARE @id_evento INT = 32955
--         ,@id_apresentacao INT = NULL
--         ,@date DATETIME = '2019-06-28'
--         ,@hour VARCHAR(5) = '21h00'
--         ,@periodtype VARCHAR(100) = 'today' --- all, thirty, fifteen, seven, yesterday, today, custom
--         ,@periodInit DATETIME = NULL
--         ,@periodEnd DATETIME = NULL

-- DECLARE @id_evento INT = 43864
--         ,@id_apresentacao INT = NULL
--         ,@date DATETIME = '2019-07-12'
--         ,@hour VARCHAR(5) = '20h00'
--         ,@periodtype VARCHAR(100) = 'seven' --- all, thirty, fifteen, seven, yesterday, today, custom
--         ,@periodInit DATETIME = NULL
--         ,@periodEnd DATETIME = NULL

-- SELECT @id_evento
--         ,@id_apresentacao
--         ,@date
--         ,@hour
--         ,@periodtype
--         ,@periodInit
--         ,@periodEnd

-- return;

IF @id_apresentacao = 0
    SET @id_apresentacao = NULL

IF @id_apresentacao = 0
    SET @id_apresentacao = NULL

IF @id_apresentacao = 0
    SET @id_apresentacao = NULL

SET NOCOUNT ON;

DECLARE  @periodInitPast DATETIME
        ,@periodEndPast DATETIME

IF @periodtype = 'all'
BEGIN
    SET @periodInit = NULL
    SET @periodEnd = NULL
END
IF @periodtype = 'thirty'
BEGIN
    SET @periodInit = CONVERT(VARCHAR(10),DATEADD(day, -30, GETDATE()),120)
    SET @periodEnd = GETDATE()

    SET @periodInitPast = CONVERT(VARCHAR(10),DATEADD(day, -60, GETDATE()),120)
    SET @periodEndPast = CONVERT(VARCHAR(10),DATEADD(day, -30, GETDATE()),120)
END
IF @periodtype = 'fifteen'
BEGIN
    SET @periodInit = CONVERT(VARCHAR(10),DATEADD(day, -15, GETDATE()),120)
    SET @periodEnd = GETDATE()

    SET @periodInitPast = CONVERT(VARCHAR(10),DATEADD(day, -30, GETDATE()),120)
    SET @periodEndPast = CONVERT(VARCHAR(10),DATEADD(day, -15, GETDATE()),120)
END
IF @periodtype = 'seven'
BEGIN
    SET @periodInit = CONVERT(VARCHAR(10),DATEADD(day, -7, GETDATE()),120)
    SET @periodEnd = GETDATE()

    SET @periodInitPast = CONVERT(VARCHAR(10),DATEADD(day, -14, GETDATE()),120)
    SET @periodEndPast = CONVERT(VARCHAR(10),DATEADD(day, -7, GETDATE()),120)
END
IF @periodtype = 'yesterday'
BEGIN
    SET @periodInit = CONVERT(VARCHAR(10),DATEADD(day, -1, GETDATE()),120)
    SET @periodEnd = GETDATE()

    SET @periodInitPast = CONVERT(VARCHAR(10),DATEADD(day, -2, GETDATE()),120)
    SET @periodEndPast = CONVERT(VARCHAR(10),DATEADD(day, -1, GETDATE()),120)
END
IF @periodtype = 'today'
BEGIN
    SET @periodInit = CONVERT(VARCHAR(10),DATEADD(day, 0, GETDATE()),120)
    SET @periodEnd = GETDATE()

    SET @periodInitPast = CONVERT(VARCHAR(10),DATEADD(day, -1, GETDATE()),120)
    SET @periodEndPast = CONVERT(VARCHAR(10),DATEADD(day, 0, GETDATE()),120)
END

-- select @periodInit,@periodEnd
-- select @periodInitPast,@periodEndPast
-- return;

IF OBJECT_ID('tempdb.dbo.#ids', 'U') IS NOT NULL
    DROP TABLE #ids; 

IF OBJECT_ID('tempdb.dbo.#resultAux', 'U') IS NOT NULL
    DROP TABLE #resultAux; 

IF OBJECT_ID('tempdb.dbo.#resultAuxPast', 'U') IS NOT NULL
    DROP TABLE #resultAuxPast; 

IF OBJECT_ID('tempdb.dbo.#resultToCount', 'U') IS NOT NULL
    DROP TABLE #resultToCount; 

IF OBJECT_ID('tempdb.dbo.#resultToCountPast', 'U') IS NOT NULL
    DROP TABLE #resultToCountPast; 

IF OBJECT_ID('tempdb.dbo.#resultFinal', 'U') IS NOT NULL
    DROP TABLE #resultFinal; 

IF OBJECT_ID('tempdb.dbo.#resultFinalPast', 'U') IS NOT NULL
    DROP TABLE #resultFinalPast; 

IF OBJECT_ID('tempdb.dbo.#resultAlmostThere', 'U') IS NOT NULL
    DROP TABLE #resultAlmostThere; 

IF OBJECT_ID('tempdb.dbo.#resultAlmostTherePast', 'U') IS NOT NULL
    DROP TABLE #resultAlmostTherePast; 

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

IF OBJECT_ID('tempdb.dbo.#seats', 'U') IS NOT NULL
    DROP TABLE #seats; 

CREATE TABLE #resultAux (Indice INT
            ,CodTipBilhete INT
            ,CodSala INT
            ,CodSetor INT
            ,NomSala VARCHAR(1000)
            ,NomSetor VARCHAR(1000)
            ,TipBilhete VARCHAR(1000)
            ,CodTipLancamento INT
            ,ValPagto BIGINT
            ,inprocess BIT
            ,isok BIT)

CREATE TABLE #resultAuxPast (Indice INT
            ,CodTipBilhete INT
            ,CodSala INT
            ,CodSetor INT
            ,NomSala VARCHAR(1000)
            ,NomSetor VARCHAR(1000)
            ,TipBilhete VARCHAR(1000)
            ,CodTipLancamento INT
            ,ValPagto BIGINT
            ,inprocess BIT
            ,isok BIT)

DECLARE @id_base INT

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_evento WHERE id_evento=@id_evento

DECLARE @db_name VARCHAR(1000),@toExec NVARCHAR(MAX)

SELECT TOP 1 @db_name=b.ds_nome_base_sql FROM CI_MIDDLEWAY..mw_base b WHERE b.id_base=@id_base;

SET @toExec=''
SET @toExec = @toExec + 'INSERT INTO #resultAux (Indice,CodTipBilhete,CodSala,CodSetor,NomSala,NomSetor,TipBilhete,CodTipLancamento,ValPagto,inprocess,isok) '
SET @toExec = @toExec + ' SELECT DISTINCT '
SET @toExec = @toExec + ' l.Indice '
SET @toExec = @toExec + ' ,l.CodTipBilhete '
SET @toExec = @toExec + ' ,a.CodSala '
SET @toExec = @toExec + ' ,se.CodSetor '
SET @toExec = @toExec + ' ,s.NomSala '
SET @toExec = @toExec + ' ,se.NomSetor '
SET @toExec = @toExec + ' ,tb.TipBilhete '
SET @toExec = @toExec + ' ,l.CodTipLancamento '
SET @toExec = @toExec + ' ,CONVERT(BIGINT,ABS(l.ValPagto)*100) ValPagto '
SET @toExec = @toExec + ' ,(CASE WHEN pv.id_pedido_venda IS NOT NULL AND pv.in_situacao=''P'' THEN 1 ELSE 0 END) inprocess '
SET @toExec = @toExec + ' ,(CASE WHEN ls.Indice IS NOT NULL AND ls.StaCadeira=''V'' THEN 1 ELSE 0 END) isok '
SET @toExec = @toExec + ' FROM '+@db_name+'.dbo.tabLancamento l '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabTipBilhete tb ON l.CodTipBilhete=tb.CodTipBilhete '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabApresentacao a ON l.CodApresentacao=a.CodApresentacao '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabPeca p ON a.CodPeca=p.CodPeca '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSala s ON a.CodSala=s.CodSala '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSetor se ON se.CodSala=a.CodSala '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSalDetalhe sd ON sd.Indice=l.Indice AND sd.CodSala=a.CodSala AND sd.CodSetor=se.CodSetor '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento AND ap.CodApresentacao=a.CodApresentacao '
SET @toExec = @toExec + ' INNER JOIN #ids i ON ap.id_apresentacao=i.ID '
SET @toExec = @toExec + ' LEFT JOIN '+@db_name+'.dbo.tabLugSala ls ON ls.INDICE = l.indice AND ls.CODAPRESENTACAO = l.CODAPRESENTACAO AND ls.CodTipBilhete=l.CodTipBilhete '
SET @toExec = @toExec + ' LEFT JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.id_apresentacao=ap.id_apresentacao AND ipv.Indice=l.Indice AND ipv.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS '
SET @toExec = @toExec + ' LEFT JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda '
SET @toExec = @toExec + ' WHERE sd.TipObjeto=''C'' '
SET @toExec = @toExec + ' AND (@periodInit IS NULL OR l.DatVenda >= @periodInit AND l.DatVenda <= @periodEnd) '
EXEC sp_executesql @toExec, N'@periodInit DATETIME, @periodEnd DATETIME', @periodInit, @periodEnd


SET @toExec=''
SET @toExec = @toExec + 'INSERT INTO #resultAuxPast (Indice,CodTipBilhete,CodSala,CodSetor,NomSala,NomSetor,TipBilhete,CodTipLancamento,ValPagto,inprocess,isok) '
SET @toExec = @toExec + ' SELECT DISTINCT '
SET @toExec = @toExec + ' l.Indice '
SET @toExec = @toExec + ' ,l.CodTipBilhete '
SET @toExec = @toExec + ' ,a.CodSala '
SET @toExec = @toExec + ' ,se.CodSetor '
SET @toExec = @toExec + ' ,s.NomSala '
SET @toExec = @toExec + ' ,se.NomSetor '
SET @toExec = @toExec + ' ,tb.TipBilhete '
SET @toExec = @toExec + ' ,l.CodTipLancamento '
SET @toExec = @toExec + ' ,CONVERT(BIGINT,ABS(l.ValPagto)*100) ValPagto '
SET @toExec = @toExec + ' ,(CASE WHEN pv.id_pedido_venda IS NOT NULL AND pv.in_situacao=''P'' THEN 1 ELSE 0 END) inprocess '
SET @toExec = @toExec + ' ,(CASE WHEN ls.Indice IS NOT NULL AND ls.StaCadeira=''V'' THEN 1 ELSE 0 END) isok '
SET @toExec = @toExec + ' FROM '+@db_name+'.dbo.tabLancamento l '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabTipBilhete tb ON l.CodTipBilhete=tb.CodTipBilhete '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabApresentacao a ON l.CodApresentacao=a.CodApresentacao '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabPeca p ON a.CodPeca=p.CodPeca '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSala s ON a.CodSala=s.CodSala '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSetor se ON se.CodSala=a.CodSala '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSalDetalhe sd ON sd.Indice=l.Indice AND sd.CodSala=a.CodSala AND sd.CodSetor=se.CodSetor '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento AND ap.CodApresentacao=a.CodApresentacao '
SET @toExec = @toExec + ' INNER JOIN #ids i ON ap.id_apresentacao=i.ID '
SET @toExec = @toExec + ' LEFT JOIN '+@db_name+'.dbo.tabLugSala ls ON ls.INDICE = l.indice AND ls.CODAPRESENTACAO = l.CODAPRESENTACAO AND ls.CodTipBilhete=l.CodTipBilhete '
SET @toExec = @toExec + ' LEFT JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.id_apresentacao=ap.id_apresentacao AND ipv.Indice=l.Indice AND ipv.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS '
SET @toExec = @toExec + ' LEFT JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda '
SET @toExec = @toExec + ' WHERE sd.TipObjeto=''C'' '
SET @toExec = @toExec + ' AND (@periodInitPast IS NULL OR l.DatVenda >= @periodInitPast AND l.DatVenda <= @periodEndPast) '
EXEC sp_executesql @toExec, N'@periodInitPast DATETIME, @periodEndPast DATETIME', @periodInitPast, @periodEndPast


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

SELECT 
        ra.CodSala
        ,ra.NomSala
        ,ra.CodSetor
        ,ra.NomSetor
        ,ra.CodTipBilhete
        ,ra.TipBilhete
        ,ra.ValPagto
        ,ISNULL((SELECT COUNT(*) FROM #resultAuxPast sub WHERE sub.CodSala=ra.CodSala AND sub.CodSetor=ra.CodSetor AND sub.CodTipBilhete=ra.CodTipBilhete AND sub.CodTipLancamento=1 AND sub.ValPagto=ra.ValPagto AND sub.isok=1),0) sold
        ,ISNULL((SELECT SUM(sub.ValPagto) FROM #resultAuxPast sub WHERE sub.CodSala=ra.CodSala AND sub.CodSetor=ra.CodSetor AND sub.CodTipBilhete=ra.CodTipBilhete AND sub.CodTipLancamento=1 AND sub.ValPagto=ra.ValPagto AND sub.isok=1),0) soldamount
        ,ISNULL((SELECT SUM(sub.ValPagto) FROM #resultAuxPast sub WHERE sub.CodSala=ra.CodSala AND sub.CodSetor=ra.CodSetor AND sub.CodTipBilhete=ra.CodTipBilhete AND sub.CodTipLancamento=2 AND sub.ValPagto=ra.ValPagto),0) refundamount
        ,ISNULL((SELECT COUNT(*) FROM #resultAuxPast sub WHERE sub.CodSala=ra.CodSala AND sub.CodSetor=ra.CodSetor AND sub.CodTipBilhete=ra.CodTipBilhete AND sub.CodTipLancamento=2 AND sub.ValPagto=ra.ValPagto),0) refund
INTO #resultToCountPast
FROM #resultAuxPast ra
GROUP BY ra.CodSala, ra.NomSala,ra.CodSetor,ra.NomSetor,ra.CodTipBilhete,ra.TipBilhete,ra.ValPagto
ORDER BY ra.TipBilhete, ra.NomSetor

SELECT
        rf.CodSala
        ,rf.CodSetor
        ,rf.CodTipBilhete
        ,rf.NomSetor
        ,rf.TipBilhete
        ,(rf.sold) sold
        ,rf.refund
        ,rf.ValPagto
        ,FORMAT(CONVERT(DECIMAL(12,2),rf.ValPagto)/100, 'N', 'pt-br') ValPagtoformatted
        ,(rf.soldamount) soldamount
        ,FORMAT(CONVERT(DECIMAL(12,2),(rf.soldamount)/100), 'N', 'pt-br') soldamountformatted
INTO #resultAlmostThere
FROM #resultToCount rf
ORDER BY rf.TipBilhete, rf.NomSetor

SELECT
        rf.CodSala
        ,rf.CodSetor
        ,rf.CodTipBilhete
        ,rf.NomSetor
        ,rf.TipBilhete
        ,(rf.sold) sold
        ,rf.refund
        ,rf.ValPagto
        ,FORMAT(CONVERT(DECIMAL(12,2),rf.ValPagto)/100, 'N', 'pt-br') ValPagtoformatted
        ,(rf.soldamount) soldamount
        ,FORMAT(CONVERT(DECIMAL(12,2),(rf.soldamount)/100), 'N', 'pt-br') soldamountformatted
INTO #resultAlmostTherePast
FROM #resultToCountPast rf
ORDER BY rf.TipBilhete, rf.NomSetor


SELECT
        (SELECT SUM(sub.sold) FROM #resultAlmostThere sub) total_sold
        ,(SELECT SUM(sub.soldamount) FROM #resultAlmostThere sub) total_soldamount
        ,(SELECT SUM(sub.soldamount) FROM #resultAlmostThere sub)/(SELECT SUM(sub.sold) FROM #resultAlmostThere sub) averageticket
        ,FORMAT(CONVERT(DECIMAL(12,2),(SELECT SUM(sub.soldamount) FROM #resultAlmostThere sub)/100), 'N', 'pt-br') total_soldamountformatted
INTO #resultFinal
FROM #resultAlmostThere rf
ORDER BY rf.TipBilhete, rf.NomSetor

SELECT
        (SELECT SUM(sub.sold) FROM #resultAlmostTherePast sub) total_sold
        ,(SELECT SUM(sub.soldamount) FROM #resultAlmostTherePast sub) total_soldamount
        ,(SELECT SUM(sub.soldamount) FROM #resultAlmostTherePast sub)/(SELECT SUM(sub.sold) FROM #resultAlmostTherePast sub) averageticket
        ,FORMAT(CONVERT(DECIMAL(12,2),(SELECT SUM(sub.soldamount) FROM #resultAlmostTherePast sub)/100), 'N', 'pt-br') total_soldamountformatted
INTO #resultFinalPast
FROM #resultAlmostTherePast rf
ORDER BY rf.TipBilhete, rf.NomSetor

DECLARE @total_sold INT
        ,@total_soldamount INT
        ,@total_soldPast INT
        ,@total_soldamountPast INT
        ,@typeof VARCHAR(100)
        ,@typeofAmount VARCHAR(100)
        ,@per DECIMAL(12,2)
        ,@perAmount DECIMAL(12,2)

SELECT @total_sold = ISNULL((SELECT TOP 1 total_sold FROM #resultFinal),0)
        ,@total_soldamount = ISNULL((SELECT TOP 1 total_sold FROM #resultFinal),0)
        ,@total_soldPast = ISNULL((SELECT TOP 1 total_sold FROM #resultFinalPast),0)
        ,@total_soldamountPast = ISNULL((SELECT TOP 1 total_sold FROM #resultFinalPast),0)

IF (@total_soldPast = 0)
BEGIN
    SET @typeof = 'increase'
    SET @per = 100.0
    IF (@total_sold = 0)
    BEGIN
        SET @typeof = ''
        SET @per = 0
    END
END
ELSE
BEGIN
    SET @per = 100.0*(@total_sold-@total_soldPast)/@total_soldPast

    SET @typeof = 'increase'
    IF @per < 0
        SET @typeof = 'decrease'

    SET @per = ABS(@per)
END

IF (@total_soldamountPast = 0)
BEGIN
    SET @typeofAmount = 'increase'
    SET @perAmount = 100.0
    IF (@total_soldamount = 0)
    BEGIN
        SET @typeofAmount = ''
        SET @perAmount = 0
    END
END
ELSE
BEGIN
    SET @perAmount = 100.0*(@total_soldamount-@total_soldamountPast)/@total_soldamountPast

    SET @typeofAmount = 'increase'
    IF @perAmount < 0
        SET @typeofAmount = 'decrease'

    SET @perAmount = ABS(@perAmount)
END

SELECT TOP 1 total_sold
        ,total_soldamount
        ,averageticket
        ,total_soldamountformatted
        ,ISNULL((SELECT TOP 1 total_soldamountformatted FROM #resultFinalPast),0) total_soldamountformattedPast
        ,FORMAT(CONVERT(DECIMAL(12,2),averageticket)/100, 'N', 'pt-br') averageticket_formatted
        ,@total_soldPast total_soldPast
        ,@typeof typeofdiff
        ,@typeofAmount typeofdiffAmount
        ,@per per_total_diff
        ,@perAmount perAmount_total_diff
        ,FORMAT(CONVERT(DECIMAL(12,2),@per), 'N', 'pt-br') per_total_diff_formatted
        ,FORMAT(CONVERT(DECIMAL(12,2),@perAmount), 'N', 'pt-br') perAmount_total_formatted
FROM #resultFinal