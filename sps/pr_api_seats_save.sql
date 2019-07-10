-- exec sp_executesql N'EXEC pr_api_seats_save @P1,@P2,@P3,@P4,@P5',N'@P1 int,@P2 int,@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000)',43879,179598,N'78#1|74#7',N'qp_d46f770a04254154a8406a040d26c106e69b8414eee6486f92b12824b768eb8f',N'E8NNV133BDO8V88'

ALTER PROCEDURE dbo.pr_api_seats_save(@id_event INT
        ,@id_presentation INT
        ,@seats VARCHAR(MAX)
        ,@key VARCHAR(1000)
        ,@code VARCHAR(1000))

AS

-- return;


-- 43879,179598,N'78#1|74#7',N'qp_d46f770a04254154a8406a040d26c106e69b8414eee6486f92b12824b768eb8f',N'E8NNV133BDO8V88'
-- DECLARE @id_event INT = 43879
--         ,@id_presentation INT = 179598
--         ,@seats VARCHAR(MAX) = '78#1|74#7'
--         ,@key VARCHAR(1000) = 'qp_d46f770a04254154a8406a040d26c106e69b8414eee6486f92b12824b768eb8f'
--         ,@code VARCHAR(1000) = 'E8NNV133BDO8V88'


SET NOCOUNT ON;

DECLARE @now DATETIME = GETDATE()
        ,@dt_valid DATETIME = DATEADD(MI, 300, GETDATE())
        ,@id_base INT


IF OBJECT_ID('tempdb.dbo.#data_bases', 'U') IS NOT NULL
    DROP TABLE #data_bases; 

IF OBJECT_ID('tempdb.dbo.#code', 'U') IS NOT NULL
    DROP TABLE #code; 

IF OBJECT_ID('tempdb.dbo.#seats', 'U') IS NOT NULL
    DROP TABLE #seats; 

CREATE TABLE #data_bases (id_event INT
                            ,id_presentation INT
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
SET @toExec = @toExec + 'INSERT INTO #data_bases (id_event,id_presentation,sectorName,seatName,id_seat,status_seat, CodApresentacao) '
SET @toExec = @toExec + ' SELECT  '
SET @toExec = @toExec + ' ap.id_evento '
SET @toExec = @toExec + ' ,ap.id_apresentacao id_presentation '
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
    SELECT 0 success
            ,'Um dos assentos escolhidos já está vendido.' [message]
    RETURN;
END

SET @toExec=''
SET @toExec = @toExec + 'UPDATE u '
SET @toExec = @toExec + 'SET u.StaCadeira=''T'' '
SET @toExec = @toExec + ',u.CodTipBilhete=ss.tickettype '
SET @toExec = @toExec + ',u.id_session= '''+@code+''' '
SET @toExec = @toExec + 'FROM '+@db_name+'.dbo.tabLugSala u '
SET @toExec = @toExec + 'INNER JOIN #data_bases db ON u.CodApresentacao=db.CodApresentacao AND u.Indice=db.id_seat '
SET @toExec = @toExec + 'INNER JOIN #seats ss ON u.Indice=ss.id '
-- select @toExec
exec sp_executesql @toExec

-- SET @toExec=''
-- SET @toExec = @toExec + 'DELETE d '
-- SET @toExec = @toExec + 'FROM '+@db_name+'.dbo.tabResCliente d '
-- SET @toExec = @toExec + 'INNER JOIN #data_bases db ON d.CodApresentacao=db.CodApresentacao AND d.Indice=db.id_seat '
-- SET @toExec = @toExec + 'INNER JOIN #seats ss ON d.Indice=ss.id '
-- -- select @toExec
-- exec sp_executesql @toExec

DELETE d
-- SELECT *
FROM CI_MIDDLEWAY..mw_reserva d
INNER JOIN #data_bases db ON d.id_apresentacao=db.id_presentation AND d.id_cadeira=db.id_seat


INSERT INTO MW_RESERVA (ID_APRESENTACAO,ID_CADEIRA,DS_CADEIRA,DS_SETOR,ID_SESSION,DT_VALIDADE,id_apresentacao_bilhete) 
SELECT @id_presentation
        ,s.id_seat
        ,s.seatName
        ,s.sectorName
        ,@code
        ,@dt_valid
        ,ab.id_apresentacao_bilhete
FROM #data_bases s
INNER JOIN #seats ss ON s.id_seat=ss.id
INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete ab ON s.id_presentation=ab.id_apresentacao AND ab.CodTipBilhete=ss.tickettype AND ab.in_ativo=1

SELECT 1 success
        ,'Um dos assentos escolhidos já está vendido.' [message]