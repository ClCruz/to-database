
CREATE PROCEDURE dbo.pr_api_validate_data (@id_event INT
        ,@id_presentation INT
        ,@seats VARCHAR(MAX)
        ,@key VARCHAR(1000))

AS

-- DECLARE @id_event INT = 43879
--         ,@id_presentation INT = 179598
--         ,@seats VARCHAR(MAX) = '78#1|74#7'
--         ,@key VARCHAR(1000) = 'qp_d46f770a04254154a8406a040d26c106e69b8414eee6486f92b12824b768eb8f'

SET NOCOUNT ON;


DECLARE @eventOK BIT = 0
        ,@presentationOK BIT = 0
        ,@seatOK BIT = 1
        ,@tickettypeOK BIT = 1
        ,@id_base INT



SELECT @eventOK = 1 FROM CI_MIDDLEWAY..mw_evento WHERE id_evento=@id_event AND in_ativo=1

SELECT @presentationOK = 1 FROM CI_MIDDLEWAY..mw_apresentacao WHERE id_apresentacao=@id_presentation AND in_ativo=1 AND dt_apresentacao>=GETDATE()


IF OBJECT_ID('tempdb.dbo.#data_bases', 'U') IS NOT NULL
    DROP TABLE #data_bases; 

IF OBJECT_ID('tempdb.dbo.#code', 'U') IS NOT NULL
    DROP TABLE #code; 

IF OBJECT_ID('tempdb.dbo.#seats', 'U') IS NOT NULL
    DROP TABLE #seats; 

IF OBJECT_ID('tempdb.dbo.#validateitems', 'U') IS NOT NULL
    DROP TABLE #validateitems; 

    

CREATE TABLE #data_bases (id_event INT
                            ,id_presentantion INT
                            ,sectorName VARCHAR(1000)
                            ,seatName VARCHAR(1000)
                            ,id_seat INT
                            ,status_seat VARCHAR(100)
                            ,CodApresentacao INT)

CREATE TABLE #seats (id INT, tickettype INT);

INSERT INTO #seats (id, tickettype)
    SELECT SUBSTRING(Item,1,CHARINDEX('#',Item)-1), CONVERT(INT,SUBSTRING(Item,CHARINDEX('#',Item)+1,LEN(Item))) FROM dbo.splitString(@seats, '|')

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_evento WHERE id_evento=@id_event


DECLARE @db_name VARCHAR(1000),@toExec NVARCHAR(MAX)

SELECT TOP 1 @db_name=b.ds_nome_base_sql FROM CI_MIDDLEWAY..mw_base b WHERE b.id_base=@id_base;

SET @toExec=''
SET @toExec = @toExec + 'INSERT INTO #data_bases (id_event,id_presentantion,sectorName,seatName,id_seat,status_seat, CodApresentacao) '
SET @toExec = @toExec + ' SELECT  '
SET @toExec = @toExec + ' ap.id_evento '
SET @toExec = @toExec + ' ,ap.id_apresentacao id_presentantion '
SET @toExec = @toExec + ' ,se.NomSetor sectorName '
SET @toExec = @toExec + ' ,sd.NomObjeto seatName '
SET @toExec = @toExec + ' ,sd.Indice '
SET @toExec = @toExec + ' ,ls.StaCadeira '
SET @toExec = @toExec + ' ,a.CodApresentacao '
SET @toExec = @toExec + ' FROM CI_MIDDLEWAY..mw_apresentacao ap '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..quota_partner_reservation qpr ON ap.id_apresentacao=qpr.id_apresentacao '
SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..quota_partner qp ON qpr.id_quotapartner=qp.id AND qp.[key]= '''+@key+''''
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabPeca p ON e.CodPeca=p.CodPeca '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSala s ON a.CodSala=s.CodSala '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSalDetalhe sd ON sd.CodSala=a.CodSala AND sd.Indice=qpr.indice '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSetor se ON a.CodSala=se.CodSala AND sd.CodSetor=se.CodSetor '
SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabLugSala ls ON a.CodApresentacao=ls.CodApresentacao AND sd.Indice=ls.Indice '
SET @toExec = @toExec + ' INNER JOIN #seats ss ON ls.indice=ss.id '
SET @toExec = @toExec + ' WHERE ap.id_evento='+CONVERT(VARCHAR(10),@id_event)+' '
SET @toExec = @toExec + ' AND ap.id_apresentacao='+CONVERT(VARCHAR(10),@id_presentation)+' '
    -- select @toExec
exec sp_executesql @toExec

DECLARE @checksseatreserved BIT = 1
SELECT @checksseatreserved = 0 FROM #data_bases db WHERE db.status_seat != 'R'

IF @checksseatreserved = 0
BEGIN
    SET @seatOK = 0;
END

SELECT DISTINCT
ss.id
,ss.tickettype
,ISNULL((SELECT TOP 1 1 FROM #data_bases sub WHERE sub.id_seat=ss.id),0) seatok
,ISNULL((SELECT TOP 1 1 FROM mw_apresentacao_bilhete sub WHERE sub.id_apresentacao=@id_presentation AND sub.CodTipBilhete=ss.tickettype AND sub.in_ativo=1),0) tickettypeok
INTO #validateitems
FROM #seats ss

IF @seatOK=1
BEGIN
    SELECT @seatOK = 0 FROM #validateitems WHERE seatok=0
END

SELECT @tickettypeOK = 0 FROM #validateitems WHERE tickettypeok=0


SELECT @tickettypeOK tickettypeOK
        ,@seatOK seatOK
        ,@eventOK eventOK
        ,@presentationOK presentationOK