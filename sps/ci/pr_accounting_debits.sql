ALTER PROCEDURE dbo.pr_accounting_debits (@id VARCHAR(100))

AS
-- DECLARE @id VARCHAR(100) = '46e5052f-6be4-43d5-a897-172e8337e9f4'




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

IF OBJECT_ID('tempdb.dbo.#debits', 'U') IS NOT NULL
    DROP TABLE #debits; 

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
        ,[date] VARCHAR(100))

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


DECLARE @presentation DATETIME
        ,@codPeca INT

SELECT
    @codPeca=p.CodPeca
    ,@presentation=ap.dt_apresentacao
FROM CI_MIDDLEWAY..mw_apresentacao ap
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
INNER JOIN tabPeca p ON e.CodPeca=p.CodPeca
WHERE ap.id_apresentacao IN (SELECT ID FROM #ids)

INSERT INTO #accounting EXEC pr_accounting @id;

DECLARE @amount BIGINT
        ,@sold BIGINT

SELECT @amount=total_soldamount,@sold=total_sold FROM #accounting

SELECT
db.CodTipDebBordero
,tdb.DebBordero
,tdb.PerDesconto
,tdb.TipValor
,(CASE WHEN tdb.TipValor='V' THEN
    CONVERT(BIGINT,(@sold*tdb.PerDesconto)*100)
ELSE 
    @amount*(tdb.PerDesconto/100)
END) amount
INTO #debits
FROM tabDebBordero db
INNER JOIN tabTipDebBordero tdb ON db.CodTipDebBordero=tdb.CodTipDebBordero
WHERE db.CodPeca=@codPeca
AND (@presentation BETWEEN db.DatIniDebito AND db.DatFinDebito)
AND tdb.StaDebBordero='A'

DECLARE @totaldeb BIGINT
        ,@amountanddeb BIGINT

SELECT @totaldeb=SUM(d.amount) FROM #debits d
SELECT @amountanddeb=@amount-@totaldeb

SELECT
d.CodTipDebBordero
,d.DebBordero
,d.PerDesconto
,d.TipValor
,d.amount
,FORMAT(CONVERT(DECIMAL(12,2),(d.PerDesconto)), 'N', 'pt-br') PerDescontoformatted
,FORMAT(CONVERT(DECIMAL(12,2),(d.amount)/CONVERT(DECIMAL(12,2),100)), 'N', 'pt-br') amountformatted
,@totaldeb total_onlydeb
,FORMAT(CONVERT(DECIMAL(12,2),(@totaldeb)/CONVERT(DECIMAL(12,2),100)), 'N', 'pt-br') total_onlydebformatted
,@amountanddeb total_amount
,FORMAT(CONVERT(DECIMAL(12,2),(@amountanddeb)/CONVERT(DECIMAL(12,2),100)), 'N', 'pt-br') total_amountformatted
FROM #debits d


-- SELECT
-- d.CodTipDebBordero
-- ,d.DebBordero
-- ,d.PerDesconto
-- ,d.TipValor
-- FROM #debits d
-- ORDER BY d.DebBordero