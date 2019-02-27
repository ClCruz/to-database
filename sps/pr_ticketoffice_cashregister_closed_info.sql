
ALTER PROCEDURE dbo.pr_ticketoffice_cashregister_closed_info (@id_ticketoffice_cashregister UNIQUEIDENTIFIER)

AS

-- DECLARE @id_ticketoffice_cashregister UNIQUEIDENTIFIER = '8e060642-d3b0-49bb-bddb-f8ed9f182046'
/*
        select * from ticketoffice_cashregister 
        where id_ticketoffice_user='f2177e5e-f727-4906-948d-4eea9b9bbd0e'
        order by created desc
*/
SET NOCOUNT ON;

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
    ,tocrm.justification
    ,tocrc.closed
    ,tocrc.id_ticketoffice_user_closed
    ,tocrc.justification_closed
    ,tocrc.created cashOpenDate
    ,tau.name nameMoviment
    ,tauclose.name nameClose
    ,tauclose.[login] loginClose
    ,ISNULL((SELECT TOP 1 1 FROM CI_MIDDLEWAY..ticketoffice_cashregister_moviment sub WHERE sub.id_ticketoffice_cashregister=tocrc.id AND [type]='diff' AND amount!=0),0) hasDiff
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
WHERE tocrc.id=@id_ticketoffice_cashregister


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
,a.closed
,a.id_ticketoffice_user_closed
,a.justification_closed
,a.nameClose
,a.loginClose
,a.cashOpenDate
,a.hasDiff
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
GROUP BY a.id_base, a.nameMoviment, a.[type], a.ds_nome_base_sql, a.ds_nome_teatro, eccr.[desc], a.codForPagto, a.id_evento, a.ds_evento, a.orderby,a.closed
,a.id_ticketoffice_user_closed
,a.justification_closed
,a.nameMoviment
,a.nameClose
,a.loginClose
,a.cashOpenDate
,a.hasDiff
ORDER BY a.ds_evento, eccr.[desc]

SELECT
    id
    ,'R$ '+(CONVERT(VARCHAR(100),CONVERT(FLOAT,amount)/100)) amount
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
    ,CONVERT(VARCHAR(10),closed,103) + ' ' + CONVERT(VARCHAR(8),closed,114) closed
    ,CONVERT(VARCHAR(10),cashOpenDate,103) + ' ' + CONVERT(VARCHAR(8),cashOpenDate,114) cashOpenDate
    ,id_ticketoffice_user_closed
    ,justification_closed
    ,nameClose
    ,loginClose
    ,hasDiff
    ,'R$ '+CONVERT(VARCHAR(100),(CASE WHEN [type]='withdraw' AND amountbyevent<0 THEN CONVERT(FLOAT,amountbyevent*-1) ELSE CONVERT(FLOAT,amountbyevent) END)/100) amountbyevent
    ,'R$ '+(CONVERT(VARCHAR(100),CONVERT(FLOAT,amountbybase)/100)) amountbybase
    ,qtdbyevent
    ,qtdbybase
    ,howmanyevents
    ,howmanytypebyevents
    ,howmanypaymenttypebyevents
FROM #aux2
ORDER BY orderby