ALTER PROCEDURE dbo.pr_accounting_debits (@id VARCHAR(100))

AS
-- DECLARE @id VARCHAR(100) = 'BBDAB4C3-F4FB-4998-8621-F7B857B74C98'




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

IF OBJECT_ID('tempdb.dbo.#ids__acd', 'U') IS NOT NULL
    DROP TABLE #ids__acd; 

IF OBJECT_ID('tempdb.dbo.#debits__acd', 'U') IS NOT NULL
    DROP TABLE #debits__acd; 

IF OBJECT_ID('tempdb.dbo.#accounting__acd', 'U') IS NOT NULL
    DROP TABLE #accounting__acd; 

IF OBJECT_ID('tempdb.dbo.#accounting_bychannel', 'U') IS NOT NULL
    DROP TABLE #accounting_bychannel; 

IF OBJECT_ID('tempdb.dbo.#accounting_bychannel', 'U') IS NOT NULL
    DROP TABLE #accounting_bychannel; 

IF OBJECT_ID('tempdb.dbo.#resultFinal__acd', 'U') IS NOT NULL
    DROP TABLE #resultFinal__acd; 

IF OBJECT_ID('tempdb.dbo.#resultAux__acd', 'U') IS NOT NULL
    DROP TABLE #resultAux__acd; 

CREATE TABLE #accounting__acd ([local] VARCHAR(4000)
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
        ,[date] VARCHAR(100))

CREATE TABLE #ids__acd (ID INT)

IF @id_apresentacao IS NULL
BEGIN
        INSERT INTO #ids__acd (id)
        SELECT ap.id_apresentacao
        FROM CI_MIDDLEWAY..mw_apresentacao ap
        WHERE ap.id_evento=@id_evento
        AND ap.dt_apresentacao=@date
        AND ap.hr_apresentacao=@hour
END
ELSE
BEGIN
        INSERT INTO #ids__acd (id)
        SELECT @id_apresentacao
END


DECLARE @presentation DATETIME
        ,@codPeca INT

SELECT
    @codPeca=p.CodPeca
    ,@presentation=ap.dt_apresentacao
FROM CI_MIDDLEWAY..mw_apresentacao ap
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
INNER JOIN tabPeca p ON e.CodPeca=p.CodPeca
WHERE ap.id_apresentacao IN (SELECT ID FROM #ids__acd)

INSERT INTO #accounting__acd EXEC pr_accounting @id;

DECLARE @amount BIGINT
        ,@sold BIGINT

SELECT @amount=total_soldamount,@sold=total_sold FROM #accounting__acd

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
        ,(CASE WHEN pv.id_pedido_venda IS NOT NULL AND pv.in_situacao='F' THEN 'web' ELSE 'ticketoffice' END) channel
        ,ISNULL((SELECT TOP 1 1 FROM tabLancamento sub WHERE sub.NumLancamento=l.NumLancamento AND sub.Indice=l.Indice AND sub.CodTipBilhete=l.CodTipBilhete AND sub.CodApresentacao=l.CodApresentacao AND sub.CodTipLancamento=2),0) hasRefund
        ,fp.PcTxAdm taxa_administrativa
        ,fp.PrzRepasseDias
INTO #resultAux__acd
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
WHERE ap.id_apresentacao IN (SELECT ID FROM #ids__acd) AND sd.TipObjeto='C' AND l.CodTipLancamento=1

DECLARE @total INT = 0

SELECT @total = COUNT(*) FROM #resultAux__acd

SELECT
ra.channel
,COUNT(*) [count]
,SUM(ra.ValPagto) amount
,FORMAT(CONVERT(DECIMAL(12,2),(SUM(ra.ValPagto)))/100, 'N', 'pt-br') amount_formatted
,(CONVERT(DECIMAL(16,2),(COUNT(*))/CONVERT(DECIMAL(16,2),@total))*CONVERT(DECIMAL(16,2),100)) [percentage]
,FORMAT((CONVERT(DECIMAL(16,2),(COUNT(*))/CONVERT(DECIMAL(16,2),@total))*CONVERT(DECIMAL(16,2),100)), 'N', 'pt-br') percentage_formatted
INTO #resultFinal__acd
FROM #resultAux__acd ra
GROUP BY ra.channel

SELECT
db.CodTipDebBordero
,tdb.DebBordero
,tdb.PerDesconto
,tdb.TipValor
,(CASE WHEN tdb.TipValor='V' THEN
    CONVERT(BIGINT,((CASE WHEN tdb.sell_channel IS NULL THEN @sold ELSE rf.count END)*(tdb.PerDesconto*100)))
ELSE 
    (CASE WHEN tdb.sell_channel IS NULL THEN @amount ELSE rf.amount END)*(tdb.PerDesconto/100)
END) amount
,tdb.sell_channel
INTO #debits__acd
FROM tabDebBordero db
INNER JOIN tabTipDebBordero tdb ON db.CodTipDebBordero=tdb.CodTipDebBordero
LEFT JOIN #resultFinal__acd rf ON tdb.sell_channel=rf.channel
WHERE db.CodPeca=@codPeca
AND (@presentation BETWEEN db.DatIniDebito AND db.DatFinDebito)
AND tdb.StaDebBordero='A'

-- return;

DECLARE @totaldeb BIGINT
        ,@amountanddeb BIGINT

SELECT @totaldeb=SUM(d.amount) FROM #debits__acd d
SELECT @amountanddeb=@amount-@totaldeb

SELECT
d.CodTipDebBordero
,(d.DebBordero + (CASE WHEN d.sell_channel IS NULL THEN '' WHEN d.sell_channel = 'ticketoffice' THEN ' (por canal - Bilheteria)'  WHEN d.sell_channel = 'web' THEN ' (por canal - Internet)' END)) DebBordero
,d.PerDesconto
,d.TipValor
,d.amount
,FORMAT(CONVERT(DECIMAL(12,2),(d.PerDesconto)), 'N', 'pt-br') PerDescontoformatted
,FORMAT(CONVERT(DECIMAL(12,2),(d.amount)/CONVERT(DECIMAL(12,2),100)), 'N', 'pt-br') amountformatted
,@totaldeb total_onlydeb
,FORMAT(CONVERT(DECIMAL(12,2),(@totaldeb)/CONVERT(DECIMAL(12,2),100)), 'N', 'pt-br') total_onlydebformatted
,@amountanddeb total_amount
,FORMAT(CONVERT(DECIMAL(12,2),(@amountanddeb)/CONVERT(DECIMAL(12,2),100)), 'N', 'pt-br') total_amountformatted
FROM #debits__acd d