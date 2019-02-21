-- pr_ticketoffice_cashregister_list 'f2177e5e-f727-4906-948d-4eea9b9bbd0e', 'open', 'resultbybase'
-- pr_ticketoffice_cashregister_list 'f2177e5e-f727-4906-948d-4eea9b9bbd0e', 'open', 'resultbyevent'
-- pr_ticketoffice_cashregister_list 'f2177e5e-f727-4906-948d-4eea9b9bbd0e', 'open', 'resultbyall'

ALTER PROCEDURE dbo.pr_ticketoffice_cashregister_list (@id_ticketoffice_user UNIQUEIDENTIFIER, @date VARCHAR(100), @resultBy VARCHAR(100), @id_base INT, @id_ticketoffice_cashregister UNIQUEIDENTIFIER)

AS

-- DECLARE @id_ticketoffice_user UNIQUEIDENTIFIER = 'f2177e5e-f727-4906-948d-4eea9b9bbd0e'
--         , @date VARCHAR(100) = 'open'
--         , @id_base INT = 0
--         , @resultBy VARCHAR(100) = 'resultbybase'
--         -- , @resultBy VARCHAR(100) = 'resultbybase'
--         -- , @resultBy VARCHAR(100) = 'resultbyevent'
--         -- , @resultBy VARCHAR(100) = 'resultbyall'
--         -- , @date VARCHAR(100) = '11/02/2019'

SET NOCOUNT ON;

IF @id_base = 0
BEGIN
    SET @id_base = NULL
END

IF @date = 'open'
BEGIN
    SET @date = NULL
    SET @id_ticketoffice_cashregister = NULL
END

IF OBJECT_ID('tempdb.dbo.#bases', 'U') IS NOT NULL
    DROP TABLE #bases; 

IF OBJECT_ID('tempdb.dbo.#aux', 'U') IS NOT NULL
    DROP TABLE #aux; 

IF OBJECT_ID('tempdb.dbo.#aux2', 'U') IS NOT NULL
    DROP TABLE #aux2; 

IF OBJECT_ID('tempdb.dbo.#execcr', 'U') IS NOT NULL
    DROP TABLE #execcr; 


CREATE TABLE #bases (id_base INT, done BIT, [name] VARCHAR(1000))

CREATE TABLE #execcr (id_base INT, id int, [desc] VARCHAR(100));


SELECT
    tocrm.id
    ,b.ds_nome_teatro
    ,b.ds_nome_base_sql
    ,tocrm.amount
    ,tocrm.codForPagto
    ,tocrm.codVenda
    ,tocrm.isopen
    ,tocrm.[type]
    ,tau.name nameMoviment
    ,tauclose.name nameClose
    ,(CASE WHEN tocrm.id_evento IS NOT NULL THEN 3
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='diff' THEN 0
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='cashdepositopen' THEN 1
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='cashdeposit' THEN 2
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='withdraw' THEN 3
            END) orderby
    ,(CASE WHEN tocrm.id_evento IS NOT NULL THEN e.ds_evento
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='cashdepositopen' THEN 'Abertura de Caixa'
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='cashdeposit' THEN 'Deposito'
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='withdraw' THEN 'Saque'
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='diff' THEN 'Diferença de Caixa'
            END) ds_evento
    ,tocrm.id_base
    ,CONVERT(VARCHAR(10),tocrm.created,103) + ' ' + CONVERT(VARCHAR(8),tocrm.created,114) created
    ,tocrm.created createddate
    ,(CASE WHEN tocrm.id_evento IS NOT NULL THEN e.id_evento
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='cashdepositopen' THEN -1
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='cashdeposit' THEN -2
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='withdraw' THEN -3
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='diff' THEN -4
            END) id_evento
INTO #aux
FROM CI_MIDDLEWAY..ticketoffice_cashregister_moviment tocrm
INNER JOIN CI_MIDDLEWAY..to_admin_user tau ON tocrm.id_ticketoffice_user=tau.id
INNER JOIN CI_MIDDLEWAY..mw_base b ON tocrm.id_base=b.id_base
LEFT JOIN CI_MIDDLEWAY..ticketoffice_cashregister tocrc ON tocrm.id_ticketoffice_cashregister=tocrc.id
LEFT JOIN CI_MIDDLEWAY..to_admin_user tauclose ON tocrc.id_ticketoffice_user_closed=tauclose.id
LEFT JOIN CI_MIDDLEWAY..mw_evento e ON tocrm.id_evento=e.id_evento
WHERE tocrm.id_ticketoffice_user=@id_ticketoffice_user
-- AND (@date IS NULL OR CONVERT(VARCHAR(10),tocrc.closed,103)=@date)
AND (@date IS NOT NULL OR tocrm.isopen=1)
AND (@id_base IS NULL OR tocrm.id_base=@id_base)
AND (@date IS NULL OR tocrc.id_ticketoffice_user_closed=@id_ticketoffice_cashregister)


INSERT INTO #bases (id_base, done, [name])
SELECT DISTINCT id_base, 0, ds_nome_base_sql
FROM #aux 


WHILE (EXISTS (SELECT 1 FROM #bases WHERE done=0 ))
BEGIN
    DECLARE @currentBase INT = 0
            ,@db_name VARCHAR(1000)
            ,@toExec NVARCHAR(MAX)

    SELECT TOP 1 @currentBase=id_base
                ,@db_name=[name] FROM #bases WHERE done=0 ORDER BY id_base

    SET @toExec=''
    SET @toExec = 'INSERT INTO #execcr (id_base, id, [desc]) '
    SET @toExec = @toExec+' SELECT '+CONVERT(VARCHAR(10),@currentBase)+',fp.CodForPagto, tfp.TipForPagto '
    SET @toExec = @toExec+' FROM ['+@db_name+']..tabForPagamento fp '
    SET @toExec = @toExec+' INNER JOIN ['+@db_name+']..tabTipForPagamento tfp ON fp.CodTipForPagto=tfp.CodTipForPagto '

    exec sp_executesql @toExec
    
    UPDATE #bases SET done=1 WHERE id_base=@currentBase;
END


-- select * from #aux order by createddate

SELECT
newid() id
,SUM(a.amount) amount
,COUNT(a.amount) qtd
,a.id_base
,a.ds_nome_base_sql
,a.ds_nome_teatro
,a.[type]
,eccr.[desc]
,a.codForPagto
,a.id_evento
,a.ds_evento
,a.nameMoviment
,a.orderby
,(
    ISNULL((SELECT SUM(sub.amount) FROM #aux sub WHERE sub.id_evento=a.id_evento AND [type] NOT IN ('withdraw','refund')),0)
    -
    ISNULL((SELECT SUM(sub.amount) FROM #aux sub WHERE sub.id_evento=a.id_evento AND [type] IN ('withdraw','refund')),0)
) amountbyevent
,(
    ISNULL((SELECT SUM(sub.amount) FROM #aux sub WHERE sub.id_base=a.id_base AND [type] NOT IN ('withdraw','refund')),0)
    -
    ISNULL((SELECT SUM(sub.amount) FROM #aux sub WHERE sub.id_base=a.id_base AND [type] IN ('withdraw','refund')),0)
) amountbybase
,(SELECT COUNT(sub.amount) FROM #aux sub WHERE sub.id_evento=a.id_evento) qtdbyevent
,(SELECT COUNT(sub.amount) FROM #aux sub WHERE sub.id_base=a.id_base) qtdbybase
,(SELECT COUNT(DISTINCT sub.id_evento) FROM #aux sub) howmanyevents
,(SELECT COUNT(DISTINCT sub.[type]) FROM #aux sub where sub.id_evento=a.id_evento) howmanytypebyevents
,(SELECT COUNT(DISTINCT sub.codForPagto) FROM #aux sub where sub.id_evento=a.id_evento AND sub.[type]=a.[type]) howmanypaymenttypebyevents
INTO #aux2
FROM #aux a
INNER JOIN #execcr eccr ON a.codForPagto=eccr.id AND a.id_base=eccr.id_base
GROUP BY a.id_base, a.nameMoviment, a.[type], a.ds_nome_base_sql, a.ds_nome_teatro, eccr.[desc], a.codForPagto, a.id_evento, a.ds_evento, a.orderby--, a.createddate
ORDER BY a.ds_evento, eccr.[desc]


IF @resultBy = 'resultbybase'
BEGIN
    SELECT
        a2.id_base
        ,a2.ds_nome_teatro
        ,a2.qtdbybase
        ,a2.amountbybase
        ,(1+COUNT(*)+(SELECT SUM(subt.total) FROM (SELECT COUNT(DISTINCT sub.id_evento) total FROM #aux2 sub WHERE id_base=a2.id_base GROUP BY sub.id_base, sub.id_evento) as subt)) total
    FROM #aux2 a2
    GROUP BY a2.id_base,a2.ds_nome_teatro,a2.qtdbybase,a2.amountbybase
END

IF @resultBy = 'resultbyevent'
BEGIN
    SELECT
        a2.id_base
        ,a2.ds_nome_teatro
        ,a2.id_evento
        ,a2.ds_evento
        ,a2.qtdbyevent
        -- ,a2.amountbyevent
        ,(CASE WHEN id_evento=-3 AND amountbyevent<0 THEN amountbyevent*-1 ELSE amountbyevent END) amountbyevent
        ,(1+COUNT(*)) total
    FROM #aux2 a2
    GROUP BY a2.id_base,a2.ds_nome_teatro,a2.id_evento,a2.ds_evento,a2.qtdbyevent,a2.amountbyevent, a2.orderby
    ORDER BY a2.orderby, a2.ds_evento
END

IF @resultBy = 'resultbypayment'
BEGIN
    SELECT
        a2.id_base
        ,a2.ds_nome_teatro
        ,a2.codForPagto
        ,a2.[desc]
        ,(
            ISNULL((SELECT SUM(sub.amount) FROM #aux sub WHERE sub.id_base=a2.id_base AND sub.codForPagto=a2.codForPagto AND [type] NOT IN ('withdraw','refund')),0)
            -
            ISNULL((SELECT SUM(sub.amount) FROM #aux sub WHERE sub.id_base=a2.id_base AND sub.codForPagto=a2.codForPagto AND [type] IN ('withdraw','refund')),0)
        ) amountbypayment
        ,0 amountbypaymentinput
    FROM #aux2 a2
    GROUP BY a2.id_base,a2.ds_nome_teatro,a2.[desc],a2.codForPagto
END


IF @resultBy = 'resultbyall'
BEGIN
    SELECT
    id
    ,amount
    ,qtd
    ,id_base
    ,ds_nome_base_sql
    ,ds_nome_teatro
    ,[type]
    ,[desc]
    ,codForPagto
    ,id_evento
    ,ds_evento
    ,nameMoviment
    ,(CASE WHEN [type]='withdraw' AND amountbyevent<0 THEN amountbyevent*-1 ELSE amountbyevent END) amountbyevent
    ,amountbybase
    ,qtdbyevent
    ,qtdbybase
    ,howmanyevents
    ,howmanytypebyevents
    ,howmanypaymenttypebyevents
    FROM #aux2
END