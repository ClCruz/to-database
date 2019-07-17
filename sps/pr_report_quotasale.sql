-- exec sp_executesql N'EXEC pr_report_partnersale @P1,@P2,@P3,@P4',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000)',N'7.89',N'2019-04-01',N'2019-05-20',N'sazarte'


ALTER PROCEDURE dbo.pr_report_quotasale (@comission FLOAT
        ,@dtinit VARCHAR(10)
        ,@dtend VARCHAR(10)
        ,@id_quotapartner UNIQUEIDENTIFIER)

AS

-- DECLARE @comission FLOAT = 7.89
--         ,@dtinit VARCHAR(10) = '2019-01-01'
--         ,@dtend VARCHAR(10) = '2019-07-31'
--         ,@id_quotapartner UNIQUEIDENTIFIER = 'bfbf240a-a026-4ce4-945b-575098046c98'

SET @dtinit = @dtinit + ' 00:00:00';
SET @dtend = @dtend + ' 23:59:59';

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#result', 'U') IS NOT NULL
    DROP TABLE #result; 

IF OBJECT_ID('tempdb.dbo.#bases', 'U') IS NOT NULL
    DROP TABLE #bases; 


CREATE TABLE #result (codVenda VARCHAR(100), NomPeca VARCHAR(MAX), DatVenda VARCHAR(10), DatApresentacao VARCHAR(10), HorSessao VARCHAR(5), vl_total_pedido_venda DECIMAL(16,2)
,TipForPagto VARCHAR(1000), comission_amount DECIMAL(18,4), comission FLOAT, Nome VARCHAR(1000), EMail VARCHAR(1000), CPF VARCHAR(50), db_name VARCHAR(1000), id_base INT)

CREATE TABLE #bases (id_base INT, done BIT)

INSERT INTO #bases (id_base, done)
SELECT DISTINCT b.id_base, 0
FROM CI_MIDDLEWAY..mw_base b
WHERE b.in_ativo=1

WHILE (EXISTS (SELECT 1 FROM #bases WHERE done=0 ))
BEGIN
    DECLARE @currentBase INT = 0
            ,@db_name VARCHAR(1000)
            ,@ds_nome_teatro VARCHAR(1000)
            ,@toExec NVARCHAR(MAX)

    SELECT TOP 1 @currentBase=id_base FROM #bases WHERE done=0 ORDER BY id_base
    SELECT TOP 1 @db_name=b.ds_nome_base_sql, @ds_nome_teatro=b.ds_nome_teatro FROM CI_MIDDLEWAY..mw_base b WHERE b.id_base=@currentBase;

    SET @toExec=''
    SET @toExec = @toExec + 'INSERT INTO #result (codVenda,NomPeca,DatVenda,DatApresentacao,HorSessao,vl_total_pedido_venda,TipForPagto,comission_amount,comission,Nome,EMail,CPF, db_name, id_base) '
    SET @toExec = @toExec + 'SELECT DISTINCT '
    SET @toExec = @toExec + 'ls.CodVenda '
    SET @toExec = @toExec + ',p.NomPeca '
    SET @toExec = @toExec + ',CONVERT(VARCHAR(10),l.DatVenda,103) DatVenda '
    SET @toExec = @toExec + ',CONVERT(VARCHAR(10),a.DatApresentacao,103) DatApresentacao '
    SET @toExec = @toExec + ',a.HorSessao '
    SET @toExec = @toExec + ',SUM(l.ValPagto) vl_total_pedido_venda '
    SET @toExec = @toExec + ',tfp.TipForPagto '
    SET @toExec = @toExec + ',CONVERT(DECIMAL(18,2),(ROUND(CONVERT(DECIMAL(18,4),SUM(l.ValPagto))*(@comission)/100,2))) comission_amount '
    SET @toExec = @toExec + ',@comission comission '
    SET @toExec = @toExec + ',cli.Nome '
    SET @toExec = @toExec + ',cli.EMail '
    SET @toExec = @toExec + ',cli.CPF '
    SET @toExec = @toExec + ',@ds_nome_teatro '
    SET @toExec = @toExec + ',@id_base '
    SET @toExec = @toExec + 'FROM '+@db_name+'.dbo.tabLugSala ls '
    SET @toExec = @toExec + 'INNER JOIN '+@db_name+'.dbo.tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao '
    SET @toExec = @toExec + 'INNER JOIN '+@db_name+'.dbo.tabPeca p ON a.CodPeca=p.CodPeca '
    SET @toExec = @toExec + 'INNER JOIN '+@db_name+'.dbo.tabLancamento l ON ls.CodApresentacao=l.CodApresentacao AND ls.Indice=l.Indice '
    SET @toExec = @toExec + 'INNER JOIN '+@db_name+'.dbo.tabHisCliente hc ON hc.CodApresentacao=ls.CodApresentacao AND hc.Indice=ls.Indice AND l.NumLancamento=hc.NumLancamento '
    SET @toExec = @toExec + 'INNER JOIN '+@db_name+'.dbo.tabCliente cli ON hc.Codigo=cli.Codigo '
    SET @toExec = @toExec + 'INNER JOIN '+@db_name+'.dbo.tabForPagamento fp ON l.CodForPagto=fp.CodForPagto '
    SET @toExec = @toExec + 'INNER JOIN '+@db_name+'.dbo.tabTipForPagamento tfp ON fp.CodTipForPagto=tfp.CodTipForPagto '
    SET @toExec = @toExec + 'WHERE ls.id_quotapartner=@id_quotapartner '
    SET @toExec = @toExec + 'AND ls.StaCadeira=''V'' '
    SET @toExec = @toExec + 'GROUP BY  '
    SET @toExec = @toExec + 'ls.CodVenda '
    SET @toExec = @toExec + ',p.NomPeca '
    SET @toExec = @toExec + ',CONVERT(VARCHAR(10),l.DatVenda,103) '
    SET @toExec = @toExec + ',CONVERT(VARCHAR(10),a.DatApresentacao,103) '
    SET @toExec = @toExec + ',a.HorSessao '
    SET @toExec = @toExec + ',tfp.TipForPagto '
    SET @toExec = @toExec + ',cli.Nome '
    SET @toExec = @toExec + ',cli.EMail '
    SET @toExec = @toExec + ',cli.CPF '

    -- print @toExec

    EXEC sp_executesql @toExec, N'@id_quotapartner UNIQUEIDENTIFIER, @comission FLOAT, @ds_nome_teatro VARCHAR(1000), @id_base INT', @id_quotapartner, @comission, @ds_nome_teatro, @currentBase
    
    UPDATE #bases SET done=1 WHERE id_base=@currentBase;
END

DECLARE @total DECIMAL(18,2) = 0
        ,@total_comission DECIMAL(18,2) = 0


SELECT @total=SUM(r.vl_total_pedido_venda) FROM #result r
SELECT @total_comission=SUM(r.comission_amount) FROM #result r


SELECT 
r.CodVenda
,r.NomPeca
,r.DatVenda
,r.DatApresentacao
,r.HorSessao
,r.vl_total_pedido_venda
,r.TipForPagto
,r.comission_amount
,r.comission
,r.Nome
,r.EMail
,r.CPF
,FORMAT(CONVERT(DECIMAL(18,2),(@total)), 'N', 'pt-br') total_formatted
,FORMAT(CONVERT(DECIMAL(18,2),(@total_comission)), 'N', 'pt-br') total_comission_formatted
,@total total
,@total_comission total_comission
,FORMAT(CONVERT(DECIMAL(18,2),r.comission_amount), 'N', 'pt-br') comission_amount_formatted
,r.db_name
,r.id_base
FROM #result r
