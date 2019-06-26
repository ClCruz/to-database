-- exec sp_executesql N'EXEC pr_dashboard_purchase_values @P1,@P2,@P3,@P4,@P5,@P6,@P7',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000),@P7 nvarchar(4000)',N'43864',N'',N'2019-07-12',N'20h00',N'all',N'',N''

ALTER PROCEDURE dbo.pr_dashboard_purchase_boleto (@id_evento INT
        ,@id_apresentacao INT
        ,@date DATETIME
        ,@hour VARCHAR(5)
        ,@periodtype VARCHAR(100)
        ,@periodInit DATETIME
        ,@periodEnd DATETIME)

AS

-- -- exec pr_accounting 'a705cc76-9078-4cb4-849e-0e6b31adeb52'
-- -- exec pr_accounting_debits 'a705cc76-9078-4cb4-849e-0e6b31adeb52'
-- select top 1 * from CI_MIDDLEWAY..accounting_key order by created desc

-- DECLARE @id_evento INT = 43864
--         ,@id_apresentacao INT = NULL
--         ,@date DATETIME = '2019-07-12'
--         ,@hour VARCHAR(5) = '20h00'
--         ,@periodtype VARCHAR(100) = 'today' --- all, thirty, fifteen, seven, yesterday, today, custom
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

SELECT pv.in_situacao
    ,COUNT(*) total
INTO #result
FROM CI_MIDDLEWAY..mw_item_pedido_venda ipv
INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda
INNER JOIN #ids i ON ipv.id_apresentacao=i.ID
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON ipv.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
WHERE e.in_ativo=1
AND ap.in_ativo=1
--AND (@periodInit IS NULL OR pv.dt_pedido_venda >= @periodInit AND pv.dt_pedido_venda <= @periodEnd)
AND pv.id_meio_pagamento=85
GROUP BY pv.in_situacao


DECLARE @awaiting_payment INT
        ,@expired_payment INT
        ,@ok_payment INT

SELECT 
    @awaiting_payment = ISNULL((SELECT total FROM #result WHERE in_situacao='P'),0)
    ,@expired_payment = ISNULL((SELECT total FROM #result WHERE in_situacao='E'),0)
    ,@ok_payment = ISNULL((SELECT total FROM #result WHERE in_situacao='F'),0)

IF (CONVERT(DECIMAL(12,2),@expired_payment)+CONVERT(DECIMAL(12,2),@ok_payment)) = 0
BEGIN
SELECT @awaiting_payment awaiting_payment
        ,@expired_payment expired_payment
        ,@ok_payment ok_payment
        ,0 ok_conversion
        ,FORMAT(0, 'N', 'pt-br') ok_conversionformatted
END
ELSE
BEGIN
    SELECT @awaiting_payment awaiting_payment
            ,@expired_payment expired_payment
            ,@ok_payment ok_payment
            ,CONVERT(DECIMAL(12,2),@expired_payment)/(CONVERT(DECIMAL(12,2),@expired_payment)+CONVERT(DECIMAL(12,2),@ok_payment)) ok_conversion
            ,FORMAT(CONVERT(DECIMAL(12,2),CONVERT(DECIMAL(12,2),@expired_payment)/(CONVERT(DECIMAL(12,2),@expired_payment)+CONVERT(DECIMAL(12,2),@ok_payment))*100), 'N', 'pt-br') ok_conversionformatted
END

