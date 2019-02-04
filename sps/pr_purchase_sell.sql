--pr_purchase_get_current 'j5pu5q3um4cn4hcmuetsvcf9n0'

CREATE PROCEDURE dbo.pr_purchase_sell (@id_cliente INT
        ,@totalAmount INT
        ,@id_pedido_venda INT
        ,@cd_meio_pagamento INT)

AS
--DECLARE @id_session VARCHAR(1000) = 'j5pu5q3um4cn4hcmuetsvcf9n0'


SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#bases', 'U') IS NOT NULL
    DROP TABLE #bases; 

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


    WHILE (EXISTS (SELECT 1 FROM #bases WHERE done=0 ))
    BEGIN
        DECLARE @currentBase INT = 0
                ,@db_name VARCHAR(1000)
                ,@toExec NVARCHAR(MAX)

        SELECT TOP 1 @currentBase=id_base FROM #bases WHERE done=0 ORDER BY id_base
        SELECT TOP 1 @db_name=b.ds_nome_base_sql FROM CI_MIDDLEWAY..mw_base b WHERE b.id_base=@currentBase;

        SET @toExec=''
        SET @toExec = 'INSERT INTO #execsell (success,id_base, codVenda, id_pedido_venda,ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage) EXEC dbo.'+@db_name+'.dbo.pr_sell_web '+CONVERT(VARCHAR(10),@id_cliente)+', '+CONVERT(VARCHAR(10),@totalAmount)+', '+CONVERT(VARCHAR(10),@id_pedido_venda)+', '+CONVERT(VARCHAR(10),@cd_meio_pagamento)

        exec sp_executesql @toExec
        
        UPDATE #bases SET done=1 WHERE id_base=@currentBase;
    END

  COMMIT TRANSACTION sellweb
END TRY
BEGIN CATCH 
  IF (@@TRANCOUNT > 0)
   BEGIN
      ROLLBACK TRANSACTION sellweb
   END 
    SELECT
        0 success
        ,NULL codVenda
        ,@id_pedido_venda id_pedido_venda
        ,ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage
END CATCH
