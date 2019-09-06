ALTER PROCEDURE dbo.pr_accounting_channel (@id VARCHAR(100))

AS
-- DECLARE @id VARCHAR(100) = 'BBDAB4C3-F4FB-4998-8621-F7B857B74C98'
-- select * from CI_MIDDLEWAY..accounting_key

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


IF OBJECT_ID('tempdb.dbo.#ids__accc', 'U') IS NOT NULL
    DROP TABLE #ids__accc; 

IF OBJECT_ID('tempdb.dbo.#resultAux__accc', 'U') IS NOT NULL
    DROP TABLE #resultAux__accc; 

IF OBJECT_ID('tempdb.dbo.#resultToCount__accc', 'U') IS NOT NULL
    DROP TABLE #resultToCount__accc; 

IF OBJECT_ID('tempdb.dbo.#resultFinal__accc', 'U') IS NOT NULL
    DROP TABLE #resultFinal__accc; 

IF OBJECT_ID('tempdb.dbo.#accounting__accc', 'U') IS NOT NULL
    DROP TABLE #accounting__accc; 

CREATE TABLE #accounting__accc ([local] VARCHAR(4000)
        ,weekdayname VARCHAR(4000)
        ,weekdayfull VARCHAR(4000)
        ,[event] VARCHAR(4000)
        ,[responsible] VARCHAR(4000)
        ,responsibleDoc VARCHAR(4000)
        ,responsibleAddress VARCHAR(4000)
        ,[number] VARCHAR(4000)
        ,[presentation_number] VARCHAR(4000)
        ,[presentation_date] VARCHAR(4000)
        ,[presentation_hour] VARCHAR(4000)
        ,[sector] VARCHAR(4000)
        ,totalizer_all INT
        ,totalizer_notsold INT
        ,totalizer_free INT
        ,totalizer_paid INT
        ,totalizer_paid_and_free INT
        ,CodSala INT
        ,CodTipBilhete INT
        ,NomSetor VARCHAR(4000)
        ,TipBilhete VARCHAR(4000)
        ,sold INT
        ,refund INT
        ,ValPagto BIGINT
        ,ValPagtoformatted VARCHAR(4000)
        ,soldamount BIGINT
        ,soldamountformatted VARCHAR(4000)
        ,occupancyrate FLOAT
        ,total_refund BIGINT
        ,total_sold BIGINT
        ,total_soldamount BIGINT
        ,total_soldamountformatted VARCHAR(4000)
        ,[date] VARCHAR(100));

INSERT INTO #accounting__accc EXEC pr_accounting @id;

CREATE TABLE #ids__accc (ID INT);

IF @id_apresentacao IS NULL
BEGIN
        INSERT INTO #ids__accc (id)
        SELECT ap.id_apresentacao
        FROM CI_MIDDLEWAY..mw_apresentacao ap
        WHERE ap.id_evento=@id_evento
        AND ap.dt_apresentacao=@date
        AND ap.hr_apresentacao=@hour
END
ELSE
BEGIN
        INSERT INTO #ids__accc (id)
        SELECT @id_apresentacao
END

DECLARE @amount BIGINT
        ,@sold BIGINT

SELECT @amount=total_soldamount,@sold=total_sold FROM #accounting__accc

SELECT --DISTINCT
        l.Indice
        -- ,l.CodTipBilhete
        ,l.NumLancamento
        ,l.CodForPagto
        ,fp.CodTipForPagto
        ,fp.ForPagto
        ,tfp.TipForPagto
        ,a.CodSala
        ,se.CodSetor
        ,s.NomSala
        ,se.NomSetor
        -- ,tb.TipBilhete
        ,l.CodTipLancamento
        ,CONVERT(BIGINT,ABS(l.ValPagto)*100) ValPagto
        ,(CASE WHEN pv.id_pedido_venda IS NOT NULL AND pv.in_situacao='P' THEN 1 ELSE 0 END) inprocess
        ,(CASE WHEN ls.Indice IS NOT NULL AND ls.StaCadeira='V' THEN 1 ELSE 0 END) isok
        ,(CASE WHEN pv.id_pedido_venda IS NOT NULL AND pv.in_situacao='F' THEN 'Internet' ELSE 'Bilheteria' END) channel
        ,ISNULL((SELECT TOP 1 1 FROM tabLancamento sub WHERE sub.NumLancamento=l.NumLancamento AND sub.Indice=l.Indice AND sub.CodTipBilhete=l.CodTipBilhete AND sub.CodApresentacao=l.CodApresentacao AND sub.CodTipLancamento=2),0) hasRefund
        ,fp.PcTxAdm taxa_administrativa
        ,fp.PrzRepasseDias
INTO #resultAux__accc
FROM tabLancamento l
-- INNER JOIN tabTipBilhete tb ON l.CodTipBilhete=tb.CodTipBilhete
INNER JOIN tabForPagamento fp ON l.CodForPagto=fp.CodForPagto
INNER JOIN tabTipForPagamento tfp ON fp.CodTipForPagto=tfp.CodTipForPagto
INNER JOIN tabApresentacao a ON l.CodApresentacao=a.CodApresentacao
INNER JOIN tabPeca p ON a.CodPeca=p.CodPeca
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN tabSetor se ON se.CodSala=a.CodSala
INNER JOIN tabSalDetalhe sd ON sd.Indice=l.Indice AND sd.CodSala=a.CodSala AND sd.CodSetor=se.CodSetor
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento AND ap.CodApresentacao=a.CodApresentacao
LEFT JOIN tabLugSala ls ON ls.INDICE = l.indice AND ls.CODAPRESENTACAO = l.CODAPRESENTACAO AND ls.CodTipBilhete=l.CodTipBilhete
LEFT JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.id_apresentacao=ap.id_apresentacao AND ipv.Indice=l.Indice AND ipv.CodVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS
LEFT JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda
WHERE ap.id_apresentacao IN (SELECT ID FROM #ids__accc) AND sd.TipObjeto='C' AND l.CodTipLancamento=1

DECLARE @total INT = 0

SELECT @total = COUNT(*) FROM #resultAux__accc

SELECT
ra.channel
,COUNT(*) [count]
,SUM(ra.ValPagto) amount
,FORMAT(CONVERT(DECIMAL(12,2),(SUM(ra.ValPagto)))/100, 'N', 'pt-br') amount_formatted
,(CONVERT(DECIMAL(16,2),(COUNT(*))/CONVERT(DECIMAL(16,2),@total))*CONVERT(DECIMAL(16,2),100)) [percentage]
,FORMAT((CONVERT(DECIMAL(16,2),(COUNT(*))/CONVERT(DECIMAL(16,2),@total))*CONVERT(DECIMAL(16,2),100)), 'N', 'pt-br') percentage_formatted
INTO #resultFinal__accc
FROM #resultAux__accc ra
GROUP BY ra.channel


SELECT
rf.channel
,rf.[count]
,rf.amount
,rf.amount_formatted
,rf.[percentage]
,rf.percentage_formatted
,(SELECT SUM(sub.[count]) FROM #resultFinal__accc sub) count__total
,FORMAT(CONVERT(DECIMAL(12,2),((SELECT SUM(sub.amount) FROM #resultFinal__accc sub)))/100, 'N', 'pt-br') amount_formatted__total
FROM #resultFinal__accc rf