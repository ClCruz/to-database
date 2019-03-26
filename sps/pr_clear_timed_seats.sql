ALTER PROCEDURE dbo.pr_clear_timed_seats

AS


IF OBJECT_ID('tempdb.dbo.#bases', 'U') IS NOT NULL
    DROP TABLE #bases; 

IF OBJECT_ID('tempdb.dbo.#execsell', 'U') IS NOT NULL
    DROP TABLE #execsell; 

CREATE TABLE #bases (id_base INT, done BIT)

CREATE TABLE #execsell (id_session VARCHAR(100), Indice INT, CodApresentacao INT, hasReservation BIT, hasReservationOnTO BIT, id_base INT);


DELETE d
FROM CI_MIDDLEWAY..current_session_client d
INNER JOIN CI_MIDDLEWAY..mw_reserva r ON d.id_session=r.id_session COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE dt_validade <= GETDATE()

DELETE FROM CI_MIDDLEWAY..mw_reserva WHERE dt_validade<=GETDATE();

DELETE FROM CI_MIDDLEWAY..ticketoffice_shoppingcart WHERE DATEADD(MINUTE, 30, created)<=GETDATE()

INSERT INTO #bases (id_base, done)
SELECT id_base, 0 FROM CI_MIDDLEWAY..mw_base 
WHERE ds_nome_base_sql='tambemvou'
ORDER BY id_base

DECLARE @currentBase INT = 0
        ,@db_name VARCHAR(1000)
        ,@toExec NVARCHAR(MAX)

WHILE (EXISTS (SELECT 1 FROM #bases WHERE done=0 ))
BEGIN
    SELECT @currentBase = 0
        ,@db_name = ''
        ,@toExec = ''

    SELECT TOP 1 @currentBase=id_base FROM #bases WHERE done=0 ORDER BY id_base
    SELECT TOP 1 @db_name=b.ds_nome_base_sql FROM CI_MIDDLEWAY..mw_base b WHERE b.id_base=@currentBase;

    print @db_name
    SET @toExec=''
    SET @toExec = 'INSERT INTO #execsell (id_session, Indice, CodApresentacao, hasReservation, hasReservationOnTO, id_base) '
    SET @toExec = @toExec+' SELECT DISTINCT '
    SET @toExec = @toExec+' ls.id_session '
    SET @toExec = @toExec+' ,ls.Indice '
    SET @toExec = @toExec+' ,ls.CodApresentacao '
    SET @toExec = @toExec+' ,ISNULL((SELECT TOP 1 1 FROM CI_MIDDLEWAY..mw_reserva sub WHERE sub.id_cadeira=ls.indice AND sub.id_session=ls.id_session COLLATE SQL_Latin1_General_CP1_CI_AS AND sub.dt_validade>GETDATE()),0) hasReservation '
    SET @toExec = @toExec+' ,ISNULL((SELECT TOP 1 1 FROM CI_MIDDLEWAY..ticketoffice_shoppingcart sub WHERE sub.indice=ls.indice AND CONVERT(VARCHAR(1000),sub.id_ticketoffice_user)=ls.id_session COLLATE SQL_Latin1_General_CP1_CI_AS AND DATEADD(minute, 25, sub.created)>GETDATE()),0) hasReservationOnTO '
    SET @toExec = @toExec+' ,(SELECT TOP 1 id_base FROM CI_MIDDLEWAY..mw_base WHERE ds_nome_base_sql='''+@db_name+''') id_base '
    SET @toExec = @toExec+' FROM ['+@db_name+']..tabLugSala ls '
    SET @toExec = @toExec+' WHERE StaCadeira=''T'' '

    print @toExec
    exec sp_executesql @toExec
    
    UPDATE #bases SET done=1 WHERE id_base=@currentBase;
END

-- SELECT * FROM #execsell;

-- return;

DELETE FROM #execsell WHERE hasReservation!=0 OR hasReservationOnTO!=0

DELETE d
FROM CI_MIDDLEWAY..mw_reserva d
INNER JOIN #execsell e ON d.id_session=e.id_session COLLATE SQL_Latin1_General_CP1_CI_AS AND d.id_cadeira=e.Indice

DELETE d
FROM CI_MIDDLEWAY..ticketoffice_shoppingcart d
INNER JOIN #execsell e ON d.id_ticketoffice_user=e.id_session AND d.indice=e.Indice

UPDATE #bases SET done=0

WHILE (EXISTS (SELECT 1 FROM #bases WHERE done=0 ))
BEGIN
    SELECT @currentBase = 0
        ,@db_name = ''
        ,@toExec = ''

    SELECT TOP 1 @currentBase=id_base FROM #bases WHERE done=0 ORDER BY id_base
    SELECT TOP 1 @db_name=b.ds_nome_base_sql FROM CI_MIDDLEWAY..mw_base b WHERE b.id_base=@currentBase;


    SET @toExec =''
    SET @toExec ='DELETE d '
    SET @toExec = @toExec+' FROM ['+@db_name+']..tabLugSala d '
    SET @toExec = @toExec+' INNER JOIN #execsell e ON d.Indice=e.Indice AND d.id_session=e.id_session COLLATE SQL_Latin1_General_CP1_CI_AS '
    SET @toExec = @toExec+' WHERE StaCadeira=''T'' '
    exec sp_executesql @toExec
    
    UPDATE #bases SET done=1 WHERE id_base=@currentBase;
END
