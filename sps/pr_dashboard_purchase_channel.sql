ALTER PROCEDURE dbo.pr_dashboard_purchase_channel (@id_evento INT
        ,@id_apresentacao INT
        ,@date DATETIME
        ,@hour VARCHAR(5)
        ,@periodtype VARCHAR(100)
        ,@periodInit DATETIME
        ,@periodEnd DATETIME)

AS

-- DECLARE @id_evento INT = 43864
--         ,@id_apresentacao INT = NULL
--         ,@date DATETIME = '2019-07-12'
--         ,@hour VARCHAR(5) = '20h00'
--         ,@periodtype VARCHAR(100) = 'all' --- all, thirty, fifteen, seven, yesterday, today, custom
--         ,@periodInit DATETIME = NULL
--         ,@periodEnd DATETIME = NULL

-- DECLARE @id_evento INT = 32950
--         ,@id_apresentacao INT = NULL
--         ,@date DATETIME = '2019-04-13'
--         ,@hour VARCHAR(5) = '21h00'
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

IF @periodtype = 'all'
BEGIN
    SET @periodInit = NULL
    SET @periodEnd = NULL
END
IF @periodtype = 'thirty'
BEGIN
    SET @periodInit = CONVERT(VARCHAR(10),DATEADD(day, -30, GETDATE()),120)
    SET @periodEnd = GETDATE()
END
IF @periodtype = 'fifteen'
BEGIN
    SET @periodInit = CONVERT(VARCHAR(10),DATEADD(day, -15, GETDATE()),120)
    SET @periodEnd = GETDATE()
END
IF @periodtype = 'seven'
BEGIN
    SET @periodInit = CONVERT(VARCHAR(10),DATEADD(day, -7, GETDATE()),120)
    SET @periodEnd = GETDATE()
END
IF @periodtype = 'yesterday'
BEGIN
    SET @periodInit = CONVERT(VARCHAR(10),DATEADD(day, -1, GETDATE()),120)
    SET @periodEnd = GETDATE()
END
IF @periodtype = 'today'
BEGIN
    SET @periodInit = CONVERT(VARCHAR(10),DATEADD(day, 0, GETDATE()),120)
    SET @periodEnd = GETDATE()
END

IF OBJECT_ID('tempdb.dbo.#ids', 'U') IS NOT NULL
    DROP TABLE #ids; 

IF OBJECT_ID('tempdb.dbo.#resultAux', 'U') IS NOT NULL
    DROP TABLE #resultAux; 

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

CREATE TABLE #resultAux (Indice INT
            ,CodTipBilhete INT
            ,CodSala INT
            ,CodSetor INT
            ,NomSala VARCHAR(1000)
            ,NomSetor VARCHAR(1000)
            ,TipBilhete VARCHAR(1000)
            ,CodTipLancamento INT
            ,DatVenda DATETIME
            ,ValPagto BIGINT
            ,inprocess BIT
            ,isok BIT
            ,web BIT)

DECLARE @id_base INT

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_evento WHERE id_evento=@id_evento

DECLARE @db_name VARCHAR(1000),@toExec NVARCHAR(MAX)

SELECT TOP 1 @db_name=b.ds_nome_base_sql FROM CI_MIDDLEWAY..mw_base b WHERE b.id_base=@id_base;


SET @toExec=''
SET @toExec = @toExec + 'INSERT INTO #resultAux (Indice,CodTipBilhete,CodSala,CodSetor,NomSala,NomSetor,TipBilhete,CodTipLancamento, DatVenda,ValPagto,inprocess,isok, web) '
SET @toExec = @toExec + ' SELECT DISTINCT '
SET @toExec = @toExec + ' l.Indice '
SET @toExec = @toExec + ' ,l.CodTipBilhete '
SET @toExec = @toExec + ' ,a.CodSala '
SET @toExec = @toExec + ' ,se.CodSetor '
SET @toExec = @toExec + ' ,s.NomSala '
SET @toExec = @toExec + ' ,se.NomSetor '
SET @toExec = @toExec + ' ,tb.TipBilhete '
SET @toExec = @toExec + ' ,l.CodTipLancamento '
SET @toExec = @toExec + ' ,l.DatVenda '
SET @toExec = @toExec + ' ,CONVERT(BIGINT,ABS(l.ValPagto)*100) ValPagto '
SET @toExec = @toExec + ' ,(CASE WHEN pv.id_pedido_venda IS NOT NULL AND pv.in_situacao=''P'' THEN 1 ELSE 0 END) inprocess '
SET @toExec = @toExec + ' ,(CASE WHEN ls.Indice IS NOT NULL AND ls.StaCadeira=''V'' THEN 1 ELSE 0 END) isok '
SET @toExec = @toExec + ' ,(CASE WHEN pv.id_pedido_venda IS NOT NULL THEN 1 ELSE 0 END) web '
SET @toExec = @toExec + ' FROM '+@db_name+'.dbo.tabLancamento l '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabTipBilhete tb ON l.CodTipBilhete=tb.CodTipBilhete '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabApresentacao a ON l.CodApresentacao=a.CodApresentacao '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabPeca p ON a.CodPeca=p.CodPeca '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSala s ON a.CodSala=s.CodSala '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSetor se ON se.CodSala=a.CodSala '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSalDetalhe sd ON sd.Indice=l.Indice AND sd.CodSala=a.CodSala AND sd.CodSetor=se.CodSetor '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento AND ap.CodApresentacao=a.CodApresentacao '
SET @toExec = @toExec + ' LEFT JOIN '+@db_name+'.dbo.tabLugSala ls ON ls.INDICE = l.indice AND ls.CODAPRESENTACAO = l.CODAPRESENTACAO AND ls.CodTipBilhete=l.CodTipBilhete '
SET @toExec = @toExec + ' LEFT JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.id_apresentacao=ap.id_apresentacao AND ipv.Indice=l.Indice AND ipv.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS '
SET @toExec = @toExec + ' LEFT JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda '
SET @toExec = @toExec + ' WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND sd.TipObjeto=''C'' '
SET @toExec = @toExec + ' AND (@periodInit IS NULL OR l.DatVenda >= @periodInit AND l.DatVenda <= @periodEnd) '
EXEC sp_executesql @toExec, N'@periodInit DATETIME, @periodEnd DATETIME', @periodInit, @periodEnd

SELECT
ra.web
,COUNT(*) sold
FROM #resultAux ra
WHERE ra.isok=1-- AND ra.inprocess=0
GROUP BY ra.web
ORDER BY 
ra.web