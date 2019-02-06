ALTER PROCEDURE dbo.pr_purchase_sell (@id_cliente INT
        ,@totalAmount INT
        ,@id_pedido_venda INT
        ,@cd_meio_pagamento INT)

AS
-- DECLARE @id_cliente INT = 30
--         ,@totalAmount INT = 100
--         ,@id_pedido_venda INT = 52
--         ,@cd_meio_pagamento INT = 911

SET NOCOUNT ON;

DECLARE @codVenda VARCHAR(10)

IF OBJECT_ID('tempdb.dbo.#bases', 'U') IS NOT NULL
    DROP TABLE #bases; 

IF OBJECT_ID('tempdb.dbo.#execsell', 'U') IS NOT NULL
    DROP TABLE #execsell; 

IF OBJECT_ID('tempdb.dbo.#codVendaTemp', 'U') IS NOT NULL
    DROP TABLE #codVendaTemp; 

CREATE TABLE #codVendaTemp (codVenda VARCHAR(10));

CREATE TABLE #bases (id_base INT, done BIT)

CREATE TABLE #execsell (success BIT, id_base INT, codVenda VARCHAR(100), id_pedido_venda INT
                        ,ErrorNumber INT,ErrorSeverity INT,ErrorState INT,ErrorProcedure NVARCHAR(128)
                        ,ErrorLine INT,ErrorMessage NVARCHAR(4000));

INSERT INTO #bases (id_base, done)
SELECT DISTINCT e.id_base, 0
FROM CI_MIDDLEWAY..mw_reserva r
INNER JOIN CI_MIDDLEWAY..current_session_client csc ON r.id_session=csc.id_session COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON r.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO_BILHETE AB ON AB.ID_APRESENTACAO = R.ID_APRESENTACAO AND AB.IN_ATIVO = 1 AND AB.ID_APRESENTACAO_BILHETE = R.ID_APRESENTACAO_BILHETE
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
WHERE csc.id_cliente=@id_cliente

BEGIN TRY

  BEGIN TRANSACTION sellweb

  INSERT INTO #codVendaTemp EXEC CI_MIDDLEWAY..seqCodVenda @id_pedido_venda;
  SELECT TOP 1 @codVenda=codVenda FROM #codVendaTemp



    WHILE (EXISTS (SELECT 1 FROM #bases WHERE done=0 ))
    BEGIN
        DECLARE @currentBase INT = 0
                ,@db_name VARCHAR(1000)
                ,@toExec NVARCHAR(MAX)

        SELECT TOP 1 @currentBase=id_base FROM #bases WHERE done=0 ORDER BY id_base
        SELECT TOP 1 @db_name=b.ds_nome_base_sql FROM CI_MIDDLEWAY..mw_base b WHERE b.id_base=@currentBase;

        SET @toExec=''
        SET @toExec = 'INSERT INTO #execsell (success,id_base, codVenda, id_pedido_venda,ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage) '
        SET @toExec = @toExec+' EXEC ['+@db_name+']..pr_sell_web '+CONVERT(VARCHAR(10),@id_cliente)
        SET @toExec = @toExec+', '+CONVERT(VARCHAR(10),@totalAmount)
        SET @toExec = @toExec+', '+CONVERT(VARCHAR(10),@id_pedido_venda)
        SET @toExec = @toExec+', '+CONVERT(VARCHAR(10),@cd_meio_pagamento)
        SET @toExec = @toExec+', '''+@codVenda+''''
        -- print @toExec

        exec sp_executesql @toExec
        
        UPDATE #bases SET done=1 WHERE id_base=@currentBase;
    END

  DECLARE @hasError BIT = 0

  SELECT @hasError=1 FROM #execsell WHERE success=0

--   SELECT * FROM #execsell

  IF @hasError = 1
  BEGIN
    ROLLBACK TRANSACTION sellweb

    SELECT 0 success
        , (SELECT TOP 1 id_base FROM #execsell WHERE success=0) id_base
        , @codVenda codVenda
        , @id_pedido_venda id_pedido_venda
        , (SELECT TOP 1 ErrorNumber FROM #execsell WHERE success=0) AS ErrorNumber
        , (SELECT TOP 1 ErrorSeverity FROM #execsell WHERE success=0) AS ErrorSeverity
        , (SELECT TOP 1 ErrorState FROM #execsell WHERE success=0) AS ErrorState
        , (SELECT TOP 1 ErrorProcedure FROM #execsell WHERE success=0) AS ErrorProcedure
        , (SELECT TOP 1 ErrorLine FROM #execsell WHERE success=0) AS ErrorLine
        , (SELECT TOP 1 ErrorMessage FROM #execsell WHERE success=0) AS ErrorMessage
  END
  ELSE
  BEGIN
    DECLARE @id_session VARCHAR(100)

    SELECT @id_session=csc.id_session FROM CI_MIDDLEWAY..current_session_client csc WHERE csc.id_cliente=@id_cliente

    DELETE FROM CI_MIDDLEWAY..mw_reserva WHERE id_session=@id_session
    DELETE FROM CI_MIDDLEWAY..current_session_client WHERE id_cliente=@id_cliente

    COMMIT TRANSACTION sellweb

    SELECT 1 success
        , (SELECT TOP 1 id_base FROM #execsell) id_base
        , @codVenda codVenda
        , @id_pedido_venda id_pedido_venda
        ,NULL AS ErrorNumber
        ,NULL AS ErrorSeverity
        ,NULL AS ErrorState
        ,NULL AS ErrorProcedure
        ,NULL AS ErrorLine
        ,NULL AS ErrorMessage
  END

END TRY
BEGIN CATCH 
  IF (@@TRANCOUNT > 0)
   BEGIN
      ROLLBACK TRANSACTION sellweb
   END 
    SELECT
        0 success
        ,NULL id_base
        ,NULL codVenda
        ,@id_pedido_venda id_pedido_venda
        ,ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage
END CATCH
