-- exec pr_accounting 'a705cc76-9078-4cb4-849e-0e6b31adeb52'
-- exec pr_accounting_debits 'a705cc76-9078-4cb4-849e-0e6b31adeb52'

ALTER PROCEDURE dbo.pr_accounting_payment (@id VARCHAR(100))

AS
-- DECLARE @id VARCHAR(100) = '7da54974-c01e-4d05-be44-fed39970ed66'
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

IF OBJECT_ID('tempdb.dbo.#accounting', 'U') IS NOT NULL
    DROP TABLE #accounting; 

CREATE TABLE #accounting ([local] VARCHAR(4000)
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

INSERT INTO #accounting EXEC pr_accounting @id;

CREATE TABLE #ids (ID INT);

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

DECLARE @amount BIGINT
        ,@sold BIGINT

SELECT @amount=total_soldamount,@sold=total_sold FROM #accounting

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
        ,ISNULL((SELECT TOP 1 1 FROM tabLancamento sub WHERE sub.NumLancamento=l.NumLancamento AND sub.Indice=l.Indice AND sub.CodTipBilhete=l.CodTipBilhete AND sub.CodApresentacao=l.CodApresentacao AND sub.CodTipLancamento=2),0) hasRefund
        ,fp.PcTxAdm taxa_administrativa
        ,fp.PrzRepasseDias
INTO #resultAux
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
WHERE ap.id_apresentacao IN (SELECT ID FROM #ids) AND sd.TipObjeto='C' AND l.CodTipLancamento=1

SELECT 
        ra.CodForPagto
        ,ra.ForPagto
        ,ra.taxa_administrativa
        ,ra.PrzRepasseDias
        ,ISNULL((SELECT COUNT(indice) FROM #resultAux sub WHERE sub.CodForPagto=ra.CodForPagto AND sub.isok=1 AND sub.hasRefund=0),0) sold
        ,ISNULL((SELECT COUNT(indice) FROM #resultAux sub WHERE sub.CodForPagto=ra.CodForPagto AND sub.hasRefund=1),0) refund
        ,ISNULL((SELECT SUM(sub.ValPagto) FROM #resultAux sub WHERE sub.CodForPagto=ra.CodForPagto AND sub.isok=1 AND sub.hasRefund=0),0) soldamount
        ,ISNULL((SELECT SUM(sub.ValPagto) FROM #resultAux sub WHERE sub.CodForPagto=ra.CodForPagto AND sub.hasRefund=1),0) refundamount
INTO #resultToCount
FROM #resultAux ra
GROUP BY ra.CodForPagto,ra.ForPagto,ra.taxa_administrativa,ra.PrzRepasseDias
ORDER BY ra.ForPagto

SELECT
    rf.CodForPagto
    ,rf.ForPagto
    ,rf.taxa_administrativa
    ,FORMAT(rf.taxa_administrativa, 'N', 'pt-br') taxa_administrativa_formatted
    ,(rf.sold) sold
    ,(CONVERT(DECIMAL(18,3),rf.sold)/CONVERT(DECIMAL(18,3),@sold))*100 [percentage]
    ,FORMAT((CONVERT(DECIMAL(18,3),rf.sold)/CONVERT(DECIMAL(18,3),@sold))*100, 'N', 'pt-br') percentage_formatted
    ,rf.soldamount
    ,FORMAT(CONVERT(DECIMAL(12,2),rf.soldamount)/100, 'N', 'pt-br') soldamount_formatted
    ,(CONVERT(INT,((rf.soldamount)/100)*(rf.taxa_administrativa))) discount
    ,FORMAT(CONVERT(DECIMAL(12,2),(CONVERT(INT,((rf.soldamount)/100)*(rf.taxa_administrativa))))/100, 'N', 'pt-br') discount_formatted
    ,(rf.soldamount)-(CONVERT(INT,((rf.soldamount)/100)*(rf.taxa_administrativa))) total
    ,FORMAT(CONVERT(DECIMAL(12,2),(rf.soldamount)-(CONVERT(INT,((rf.soldamount)/100)*(rf.taxa_administrativa))))/100, 'N', 'pt-br') total_formatted
    ,rf.PrzRepasseDias
    ,CONVERT(VARCHAR(10),DATEADD(DAY,rf.PrzRepasseDias, @date),103) transfer_date
INTO #resultFinal
FROM #resultToCount rf
ORDER BY rf.ForPagto

SELECT
    rf.CodForPagto
    ,rf.ForPagto
    ,rf.taxa_administrativa
    ,rf.taxa_administrativa_formatted
    ,rf.sold
    ,rf.[percentage]
    ,rf.percentage_formatted
    ,rf.soldamount
    ,rf.soldamount_formatted
    ,rf.discount
    ,rf.discount_formatted
    ,rf.total
    ,rf.total_formatted
    ,rf.PrzRepasseDias
    ,rf.transfer_date
    ,(SELECT SUM(sub.sold) FROM #resultFinal sub) sold_total
    ,FORMAT(CONVERT(DECIMAL(12,2),(SELECT SUM(sub.sold) FROM #resultFinal sub)), 'N', 'pt-br') sold_total_formatted
    ,(SELECT SUM(sub.[percentage]) FROM #resultFinal sub) percentage_total
    ,FORMAT(CONVERT(DECIMAL(12,2),(SELECT SUM(sub.[percentage]) FROM #resultFinal sub)), 'N', 'pt-br') percentage_total_formatted
    ,(SELECT SUM(sub.soldamount) FROM #resultFinal sub) soldamount_total
    ,FORMAT(CONVERT(DECIMAL(12,2),(SELECT SUM(sub.soldamount) FROM #resultFinal sub))/100, 'N', 'pt-br') soldamount_total_formatted
    ,(SELECT SUM(sub.discount) FROM #resultFinal sub) discount_total
    ,FORMAT(CONVERT(DECIMAL(12,2),(SELECT SUM(sub.discount) FROM #resultFinal sub))/100, 'N', 'pt-br') discount_total_formatted
    ,(SELECT SUM(sub.total) FROM #resultFinal sub) total_total
    ,FORMAT(CONVERT(DECIMAL(12,2),(SELECT SUM(sub.total) FROM #resultFinal sub))/100, 'N', 'pt-br') total_total_formatted
FROM #resultFinal rf
ORDER BY rf.ForPagto
