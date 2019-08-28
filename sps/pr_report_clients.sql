ALTER PROCEDURE dbo.pr_report_clients (@id_base INT)

AS

-- DECLARE @id_base INT = 214

-- SELECT id_base, ds_nome_base_sql FROM CI_MIDDLEWAY..mw_base
-- 210	tixsme
-- 214	sazarteingressos
-- 279 viveringressos
-- 216	construcaoteatral
-- 253 ingressoparatodos

-- DECLARE @uniquename_partner VARCHAR(1000) = 'sazarte'


SET NOCOUNT ON;

DECLARE @uniquename_partner VARCHAR(1000)
        ,@db_name VARCHAR(1000)


SELECT @db_name = ds_nome_base_sql FROM CI_MIDDLEWAY.dbo.mw_base where id_base=@id_base
SET @uniquename_partner = dbo.fnc_rename_base_to_json(@db_name)

IF OBJECT_ID('tempdb.dbo.#result', 'U') IS NOT NULL
    DROP TABLE #result; 

IF OBJECT_ID('tempdb.dbo.#resultfinal', 'U') IS NOT NULL
    DROP TABLE #resultfinal; 

CREATE TABLE #result (id INT, [name] VARCHAR(1000), document VARCHAR(1000), email VARCHAR(1000))

INSERT INTO #result (id, name, document, email)
SELECT
c.id_cliente
,c.ds_nome + ' ' + c.ds_sobrenome
,c.cd_cpf
,c.cd_email_login
FROM CI_MIDDLEWAY..mw_cliente c
WHERE c.uniquename_partner=@uniquename_partner

DECLARE @toExec NVARCHAR(MAX)

SET @toExec=''
SET @toExec = @toExec + ' INSERT INTO #result (id, name, document, email) '
SET @toExec = @toExec + ' SELECT '
SET @toExec = @toExec + ' c.Codigo '
SET @toExec = @toExec + ' ,c.Nome '
SET @toExec = @toExec + ' ,c.CPF '
SET @toExec = @toExec + ' ,LTRIM(RTRIM((CASE WHEN cli.id_cliente IS NOT NULL THEN cli.cd_email_login COLLATE SQL_Latin1_General_CP1_CI_AS ELSE c.EMail COLLATE SQL_Latin1_General_CP1_CI_AS END))) '
SET @toExec = @toExec + ' FROM ['+@db_name+'].dbo.tabCliente c '
SET @toExec = @toExec + ' LEFT JOIN CI_MIDDLEWAY..mw_cliente cli ON c.CPF=cli.cd_cpf COLLATE SQL_Latin1_General_CP1_CI_AS AND cli.uniquename_partner=@uniquename_partner '

EXEC sp_executesql @toExec, N'@uniquename_partner VARCHAR(1000)',@uniquename_partner

SELECT DISTINCT
-- r.id
r.document
,REPLACE(RTRIM(LTRIM(dbo.fn_StripCharacters((r.name), '^a-Z,0-9,'' '''))),'  ', ' ') [name]
,ISNULL((CASE WHEN r.email = '0' THEN '' ELSE r.email END),NULL) email
INTO #resultfinal
FROM #result r
WHERE r.document IS NOT NULL 
AND r.document != ''
AND r.name != ''

-- SELECT rf.document, rf2.document, rf2.email
-- FROM #resultfinal rf
-- INNER JOIN #resultfinal rf2 ON rf.document=rf2.document AND rf2.email != '' AND rf2.email IS NOT NULL
-- return

UPDATE rf
SET rf.email=rf2.email
    ,rf.name=rf2.name
FROM #resultfinal rf
INNER JOIN #resultfinal rf2 ON rf.document=rf2.document AND rf2.email != '' AND rf2.email IS NOT NULL


SELECT
t.document
,t.email
,t.name
,ROW_NUMBER() OVER (order by t.document) [id]
FROM (
SELECT DISTINCT
rf.document
,rf.name
,rf.email
FROM #resultfinal rf) as t
ORDER BY t.name