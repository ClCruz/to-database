ALTER PROCEDURE dbo.pr_purchase_makeitbemine (@session VARCHAR(1000), @id_client INT)

AS

SET NOCOUNT ON;

DECLARE @id_client_isok BIT = 0
        ,@session_isok BIT = 0

IF OBJECT_ID('tempdb.dbo.#bases', 'U') IS NOT NULL
    DROP TABLE #bases; 

SELECT TOP 1 @id_client_isok=1 FROM CI_MIDDLEWAY..mw_cliente WHERE id_cliente=@id_client

SELECT TOP 1 @session_isok=1 FROM CI_MIDDLEWAY..mw_reserva WHERE id_session=@session
IF @id_client_isok = 1 AND @session_isok = 1
BEGIN
    SELECT DISTINCT e.id_base, 0 as done
    INTO #bases
    FROM CI_MIDDLEWAY..MW_EVENTO E
    INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO A ON A.ID_EVENTO = E.ID_EVENTO
    INNER JOIN CI_MIDDLEWAY..MW_RESERVA R ON R.ID_APRESENTACAO = A.ID_APRESENTACAO
    WHERE R.id_session = @session    

    DECLARE @has BIT = 0
            ,@newid VARCHAR(32) = @session-- REPLACE(CONVERT(VARCHAR(100),newid()),'-','')
    SELECT TOP 1 @has=1 FROM CI_MIDDLEWAY..current_session_client WHERE id_cliente=@id_client
    
    IF @has = 1
    BEGIN
        UPDATE CI_MIDDLEWAY..current_session_client SET created=GETDATE() WHERE id_cliente=@id_client
    END
    ELSE
    BEGIN
        INSERT INTO CI_MIDDLEWAY..current_session_client (id_cliente, id_session)
        SELECT @id_client,@newid
    END
-- select * from #bases

    -- UPDATE CI_MIDDLEWAY..mw_reserva SET id_session=@newid WHERE id_session=@session;
    
    -- WHILE (EXISTS (SELECT 1 FROM #bases WHERE done=0 ))
    -- BEGIN
    --     DECLARE @currentBase INT = 0
    --             ,@db_name VARCHAR(1000)
    --             ,@toExec NVARCHAR(MAX)

    --     SELECT TOP 1 @currentBase=id_base FROM #bases WHERE done=0 ORDER BY id_base
    --     SELECT TOP 1 @db_name=b.ds_nome_base_sql FROM CI_MIDDLEWAY..mw_base b WHERE b.id_base=@currentBase;

    --     SET @toExec=''
    --     SET @toExec = @toExec + 'UPDATE '+@db_name+'.dbo.tabLugSala SET id_session='''+@newid+''' WHERE id_session='''+@session+''''
        
    --     exec sp_executesql @toExec

    --     UPDATE #bases SET done=1 WHERE id_base=@currentBase;
    -- END

    SELECT 1 success
            ,'' msg
            ,@newid [session]

    RETURN;
END

SELECT 0 success
        ,'Não foi possível encontrar a sessão ou o cliente.' msg
