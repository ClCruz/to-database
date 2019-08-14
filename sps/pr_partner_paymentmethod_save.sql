-- exec sp_executesql N'EXEC pr_partner_paymentmethod_save @P1, @P2, @P3',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000)',N'286',N'85',N'56'
ALTER PROCEDURE dbo.pr_partner_paymentmethod_save (@id_base INT
        ,@id_meio_pagamento INT
        ,@codForPagto INT)

AS

-- DECLARE @id_base INT = 286
--         ,@id_meio_pagamento INT = 85
--         ,@codForPagto INT = 56

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#data_bases', 'U') IS NOT NULL
    DROP TABLE #data_bases; 

    
CREATE TABLE #data_bases (CodForPagto INT
                            ,ForPagto VARCHAR(1000))

DECLARE @db_name VARCHAR(1000),@toExec NVARCHAR(MAX)

SELECT TOP 1 @db_name=b.ds_nome_base_sql FROM CI_MIDDLEWAY..mw_base b WHERE b.id_base=@id_base;

SET @toExec=''
SET @toExec = @toExec + 'INSERT INTO #data_bases (CodForPagto, ForPagto) '
SET @toExec = @toExec + ' SELECT '
SET @toExec = @toExec + ' fp.CodForPagto '
SET @toExec = @toExec + ' ,fp.ForPagto '
SET @toExec = @toExec + ' FROM '+@db_name+'.dbo.tabForPagamento fp '
SET @toExec = @toExec + ' WHERE StaForPagto=''A'' '

exec sp_executesql @toExec


DECLARE @ForPagto VARCHAR(1000)
SELECT @ForPagto=ForPagto FROM #data_bases WHERE CodForPagto=@codForPagto


DECLARE @has BIT = 0
SELECT @has = 1 FROM CI_MIDDLEWAY..mw_meio_pagamento_forma_pagamento WHERE id_base=@id_base AND CodForPagto=@codForPagto AND id_meio_pagamento=@id_meio_pagamento

IF @has = 0
BEGIN
    INSERT INTO CI_MIDDLEWAY..mw_meio_pagamento_forma_pagamento (CodForPagto, ds_forpagto, id_base, id_meio_pagamento)
        SELECT @codForPagto
                ,@ForPagto
                ,@id_base
                ,@id_meio_pagamento
END
ELSE
BEGIN
    DELETE FROM CI_MIDDLEWAY..mw_meio_pagamento_forma_pagamento WHERE id_base=@id_base AND id_meio_pagamento=@id_meio_pagamento AND CodForPagto=@codForPagto
END
