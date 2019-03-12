CREATE PROCEDURE dbo.pr_clear_inprocess_seats

AS

-- rollback

IF OBJECT_ID('tempdb.dbo.#bases', 'U') IS NOT NULL
    DROP TABLE #bases; 

IF OBJECT_ID('tempdb.dbo.#execsell', 'U') IS NOT NULL
    DROP TABLE #execsell; 

IF OBJECT_ID('tempdb.dbo.#pedidos', 'U') IS NOT NULL
    DROP TABLE #pedidos; 

CREATE TABLE #bases (id_base INT, done BIT)

CREATE TABLE #execsell (lancamento INT, indice INT, codVenda VARCHAR(100), codApresentacao INT, id_base INT);

CREATE TABLE #pedidos (id_pedido_venda INT, indice INT, codVenda VARCHAR(100), codApresentacao INT, codPeca INT, id_base INT, base VARCHAR(1000));

INSERT INTO #pedidos (id_pedido_venda, indice, codVenda, codApresentacao, codPeca, id_base, base)
SELECT p.id_pedido_venda, ipv.Indice, ipv.CodVenda, a.CodApresentacao, e.CodPeca, b.id_base, b.ds_nome_base_sql
FROM CI_MIDDLEWAY..mw_pedido_venda p
INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON p.id_pedido_venda=ipv.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..mw_apresentacao a ON ipv.id_apresentacao=a.id_apresentacao
INNER JOIN CI_MIDDLEWAY..mw_evento e ON a.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_base b ON e.id_base=b.id_base
WHERE p.in_situacao='P'
AND DATEADD(day, 4, p.dt_pedido_venda)<=GETDATE();


INSERT INTO #bases (id_base, done)
SELECT DISTINCT id_base, 0 FROM #pedidos ORDER BY id_base

DECLARE @currentBase INT = 0
        ,@db_name VARCHAR(1000)
        ,@toExec NVARCHAR(MAX)

WHILE (EXISTS (SELECT 1 FROM #bases WHERE done=0 ))
BEGIN
    SELECT @currentBase = 0
        ,@db_name = ''
        ,@toExec = ''

    SELECT TOP 1 @currentBase=id_base FROM #bases WHERE done=0 ORDER BY id_base
    SELECT TOP 1 @db_name=b.ds_nome_base_sql FROM CI_MIDDLEWAY..mw_base b WHERE b.id_base=@currentBase;

    SET @toExec=''
    SET @toExec = 'INSERT INTO #execsell (lancamento, indice, codVenda, codApresentacao, id_base) '
    SET @toExec = @toExec+' SELECT '
    SET @toExec = @toExec+' l.NumLancamento '
    SET @toExec = @toExec+' ,p.indice '
    SET @toExec = @toExec+' ,p.codVenda '
    SET @toExec = @toExec+' ,p.codApresentacao '
    SET @toExec = @toExec+' , ' + CONVERT(VARCHAR(10),@currentBase)
    SET @toExec = @toExec+' FROM ['+@db_name+']..tabLancamento l '
    SET @toExec = @toExec+' INNER JOIN #pedidos p ON l.CodApresentacao=p.codApresentacao AND p.base='''+@db_name+''' AND l.Indice=p.indice '
    SET @toExec = @toExec+' INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON p.id_pedido_venda=pv.id_pedido_venda '

    exec sp_executesql @toExec

    SET @toExec = 'DELETE hc '
    SET @toExec = @toExec+' FROM ['+@db_name+']..tabHisCliente hc  '
    SET @toExec = @toExec+' INNER JOIN #execsell e ON e.indice=hc.Indice AND hc.NumLancamento=e.lancamento '
    exec sp_executesql @toExec

    SET @toExec = 'DELETE i '
    SET @toExec = @toExec+' FROM ['+@db_name+']..tabIngresso i '
    SET @toExec = @toExec+' INNER JOIN #execsell e ON i.Indice=e.indice AND i.CodVenda=e.codVenda COLLATE SQL_Latin1_General_CP1_CI_AS '
    exec sp_executesql @toExec

    SET @toExec = 'DELETE C '
    SET @toExec = @toExec+' FROM ['+@db_name+']..tabComprovante c '
    SET @toExec = @toExec+' INNER JOIN #execsell e ON c.CodVenda=e.codVenda COLLATE SQL_Latin1_General_CP1_CI_AS '
    exec sp_executesql @toExec


    SET @toExec = 'DELETE csv  '
    SET @toExec = @toExec+' FROM ['+@db_name+']..tabControleSeqVenda csv '
    SET @toExec = @toExec+' INNER JOIN #execsell e ON csv.Indice=e.indice AND csv.CodApresentacao=e.codApresentacao '
    exec sp_executesql @toExec

    SET @toExec = 'DELETE l '
    SET @toExec = @toExec+' FROM ['+@db_name+']..tabLancamento l '
    SET @toExec = @toExec+' INNER JOIN #execsell e ON l.NumLancamento=e.lancamento AND l.Indice=e.indice '
    exec sp_executesql @toExec

    SET @toExec = 'DELETE dp  '
    SET @toExec = @toExec+' FROM ['+@db_name+']..tabDetPagamento dp '
    SET @toExec = @toExec+' INNER JOIN #execsell e ON dp.NumLancamento=e.lancamento '
    exec sp_executesql @toExec

    SET @toExec = 'DELETE ls '
    SET @toExec = @toExec+' FROM ['+@db_name+']..tabLugSala ls '
    SET @toExec = @toExec+' INNER JOIN #execsell e ON ls.Indice=e.indice AND ls.CodApresentacao=e.codApresentacao AND ls.CodVenda=e.codVenda COLLATE SQL_Latin1_General_CP1_CI_AS '
    exec sp_executesql @toExec
    
    UPDATE #bases SET done=1 WHERE id_base=@currentBase;
END

UPDATE pv
SET pv.in_situacao = 'E'
FROM CI_MIDDLEWAY..mw_pedido_venda pv
INNER JOIN #pedidos p ON pv.id_pedido_venda=p.id_pedido_venda