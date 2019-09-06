ALTER PROCEDURE dbo.pr_report_clients_by_event (@id_base INT
                                        ,@id_evento INT
                                        ,@date DATETIME = NULL
                                        ,@hour VARCHAR(100) = NULL)

AS

-- DECLARE @id_base INT = 279
--         ,@id_evento INT = 44109
--         ,@date DATETIME = NULL
--         ,@hour VARCHAR(100) = NULL
--         -- ,@date DATETIME = '2019-08-03'
--         -- ,@hour VARCHAR(100) = '21h00'

SET NOCOUNT ON;

IF @date = '1900-01-01 00:00:00.000'
    SET @date = NULL

IF @hour = ''
    SET @hour = NULL

DECLARE @uniquename_partner VARCHAR(1000)
        ,@db_name VARCHAR(1000)


SELECT @db_name = ds_nome_base_sql FROM CI_MIDDLEWAY.dbo.mw_base where id_base=@id_base
SET @uniquename_partner = CI_MIDDLEWAY.dbo.fnc_rename_base_to_json(@db_name)

IF OBJECT_ID('tempdb.dbo.#result', 'U') IS NOT NULL
    DROP TABLE #result; 

IF OBJECT_ID('tempdb.dbo.#resultfinal', 'U') IS NOT NULL
    DROP TABLE #resultfinal; 

IF OBJECT_ID('tempdb.dbo.#ids', 'U') IS NOT NULL
    DROP TABLE #ids; 

CREATE TABLE #ids (ID INT)

CREATE TABLE #result (id INT, [name] VARCHAR(1000), document VARCHAR(1000), email VARCHAR(1000), phone VARCHAR(100), indice INT, CodApresentacao INT, seat VARCHAR(1000), codSala INT, room VARCHAR(1000), [date] datetime, hour varchar(10))

INSERT INTO #ids (id)
SELECT ap.id_apresentacao
FROM CI_MIDDLEWAY..mw_apresentacao ap
WHERE ap.id_evento=@id_evento
AND ap.in_ativo=1
AND (@date IS NULL OR ap.dt_apresentacao=@date)
AND (@hour IS NULL OR ap.hr_apresentacao=@hour)


INSERT INTO #result (id, [name], document, email, phone, indice, CodApresentacao, seat, codSala, room, [date], hour)
SELECT DISTINCT
c.id_cliente
,c.ds_nome + ' ' + c.ds_sobrenome
,c.cd_cpf
,c.cd_email_login
,(c.ds_ddd_celular+c.ds_celular)
,ipv.Indice
,ap.CodApresentacao
,sd.NomObjeto
,a.CodSala
,s.NomSala
,ap.dt_apresentacao
,ap.hr_apresentacao
FROM CI_MIDDLEWAY..mw_cliente c
INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON c.id_cliente=pv.id_cliente AND pv.in_situacao='F'
INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON pv.id_pedido_venda=ipv.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON ipv.id_apresentacao=ap.id_apresentacao
INNER JOIN #ids i ON ipv.id_apresentacao=i.ID
INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN tabSalDetalhe sd ON s.CodSala=sd.CodSala AND ipv.Indice=sd.Indice
WHERE c.uniquename_partner=@uniquename_partner


INSERT INTO #result (id, [name], document, email, phone, indice, CodApresentacao, seat, codSala, room, [date], hour)
SELECT DISTINCT
c.Codigo
,c.Nome
,c.CPF
,(CASE WHEN cli.id_cliente IS NOT NULL THEN cli.cd_email_login COLLATE SQL_Latin1_General_CP1_CI_AS ELSE c.EMail COLLATE SQL_Latin1_General_CP1_CI_AS END)
,(c.DDD+c.Telefone)
,hc.Indice
,ap.CodApresentacao
,sd.NomObjeto
,a.CodSala
,s.NomSala
,ap.dt_apresentacao
,ap.hr_apresentacao
FROM tabCliente c
INNER JOIN tabHisCliente hc ON c.Codigo=hc.Codigo
INNER JOIN tabApresentacao a ON hc.CodApresentacao=a.CodApresentacao
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao
INNER JOIN #ids i ON ap.id_apresentacao=i.ID
INNER JOIN tabLancamento l ON hc.NumLancamento=l.NumLancamento AND l.CodApresentacao=hc.CodApresentacao AND l.CodTipLancamento=1 AND hc.Indice=l.Indice
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN tabSalDetalhe sd ON s.CodSala=sd.CodSala AND hc.Indice=sd.Indice
LEFT JOIN CI_MIDDLEWAY..mw_cliente cli ON c.CPF=cli.cd_cpf COLLATE SQL_Latin1_General_CP1_CI_AS AND cli.uniquename_partner=@uniquename_partner
LEFT JOIN tabLancamento lr ON hc.NumLancamento=l.NumLancamento AND l.CodApresentacao=hc.CodApresentacao AND l.CodTipLancamento=2 AND hc.Indice=l.Indice
WHERE lr.NumLancamento IS NULL 


SELECT DISTINCT
-- r.id
r.document
,REPLACE(RTRIM(LTRIM(CI_MIDDLEWAY.dbo.fn_StripCharacters((r.name COLLATE SQL_Latin1_General_CP1_CI_AS), '^a-Z,0-9,'' '''))) COLLATE SQL_Latin1_General_CP1_CI_AS,'  ', ' ') [name]
,ISNULL((CASE WHEN r.email = '0' THEN '' ELSE r.email END),NULL) email
,r.phone
,r.indice
,r.seat
,r.room
,r.hour
,r.[date]
INTO #resultfinal
FROM #result r
WHERE r.document IS NOT NULL 
AND r.document != ''
AND r.name != ''

UPDATE rf
SET rf.email=rf2.email
    ,rf.name=rf2.name
    ,rf.phone=rf2.phone
FROM #resultfinal rf
INNER JOIN #resultfinal rf2 ON rf.document=rf2.document AND rf2.email != '' AND rf2.email IS NOT NULL

SELECT
t.document
,t.email
,t.phone
,t.name
,t.room
,t.seat
,t.indice
,t.hour
,t.[date]
,ROW_NUMBER() OVER (order by t.document) [id]
FROM (
SELECT DISTINCT
rf.document
,rf.name
,rf.email
,rf.phone
,rf.room
,rf.seat
,rf.indice
,CONVERT(VARCHAR(10),rf.[date],102) [date]
,rf.hour
FROM #resultfinal rf) as t
ORDER BY t.name