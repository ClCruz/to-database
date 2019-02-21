-- pr_ticketoffice_cashregister_list 'f2177e5e-f727-4906-948d-4eea9b9bbd0e', 'open', 'resultbybase'
-- pr_ticketoffice_cashregister_list 'f2177e5e-f727-4906-948d-4eea9b9bbd0e', 'open', 'resultbyevent'
-- pr_ticketoffice_cashregister_list 'f2177e5e-f727-4906-948d-4eea9b9bbd0e', 'open', 'resultbyall'

ALTER PROCEDURE dbo.pr_ticketoffice_cashregister_detail (@id_ticketoffice_user UNIQUEIDENTIFIER, @date VARCHAR(100), @type VARCHAR(100))

AS

-- DECLARE @id_ticketoffice_user UNIQUEIDENTIFIER = 'f2177e5e-f727-4906-948d-4eea9b9bbd0e'
--         , @date VARCHAR(100) = 'open'
--         , @type VARCHAR(100) = 'withdraw'

SET NOCOUNT ON;

IF @date = 'open'
BEGIN
    SET @date = NULL
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
    ,tocrm.justification
    ,tocrm.isopen
    ,tocrm.[type]
    ,tau.name nameMoviment
    ,tauclose.name nameClose
    ,(CASE WHEN tocrm.id_evento IS NOT NULL THEN 3
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='cashdepositopen' THEN 0
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='cashdeposit' THEN 1
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='withdraw' THEN 2
            END) orderby
    ,(CASE WHEN tocrm.id_evento IS NOT NULL THEN e.ds_evento
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='cashdepositopen' THEN 'Abertura de Caixa'
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='cashdeposit' THEN 'Deposito'
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='withdraw' THEN 'Saque'
            END) ds_evento
    ,tocrm.id_base
    ,CONVERT(VARCHAR(10),tocrm.created,103) + ' ' + CONVERT(VARCHAR(8),tocrm.created,114) created
    ,tocrm.created createddate
    ,(CASE WHEN tocrm.id_evento IS NOT NULL THEN e.id_evento
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='cashdepositopen' THEN -1
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='cashdeposit' THEN -2
            WHEN tocrm.id_evento IS NULL AND tocrm.[type]='withdraw' THEN -3
            END) id_evento
INTO #aux
FROM CI_MIDDLEWAY..ticketoffice_cashregister_moviment tocrm
INNER JOIN CI_MIDDLEWAY..to_admin_user tau ON tocrm.id_ticketoffice_user=tau.id
INNER JOIN CI_MIDDLEWAY..mw_base b ON tocrm.id_base=b.id_base
LEFT JOIN CI_MIDDLEWAY..ticketoffice_cashregister tocrc ON tocrm.id_ticketoffice_cashregister=tocrc.id
LEFT JOIN CI_MIDDLEWAY..to_admin_user tauclose ON tocrc.id_ticketoffice_user_closed=tauclose.id
LEFT JOIN CI_MIDDLEWAY..mw_evento e ON tocrm.id_evento=e.id_evento
WHERE tocrm.id_ticketoffice_user=@id_ticketoffice_user
AND (@date IS NULL OR CONVERT(VARCHAR(10),tocrc.closed,103)=@date)
AND (@date IS NOT NULL OR tocrm.isopen=1)
AND tocrm.[type]=@type


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
,a.amount
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
,a.justification
,a.created
-- INTO #aux2
FROM #aux a
INNER JOIN #execcr eccr ON a.codForPagto=eccr.id AND a.id_base=eccr.id_base
ORDER BY a.created

