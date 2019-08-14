ALTER PROCEDURE dbo.pr_partner_paymentmethod_list (@id_partner UNIQUEIDENTIFIER, @id_base INT)

AS

-- DECLARE @id_partner UNIQUEIDENTIFIER = '75FAE8CE-07BD-4125-8252-9CFEA9708087'
--         ,@id_base INT = 213

-- DECLARE @id_partner UNIQUEIDENTIFIER = '38AC1728-AB86-4DAB-9CEB-869FE4C1C2C2'
--         ,@id_base INT = 286

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


SELECT
mp.id_meio_pagamento
,mp.ds_meio_pagamento
,mp.cd_meio_pagamento
,(CASE WHEN mpfp.id_meio_pagamento IS NULL THEN 0 ELSE 1 END) active
,mpfp.CodForPagto
,db.ForPagto
,@id_base id_base
,0 edit
FROM CI_MIDDLEWAY..mw_meio_pagamento mp
LEFT JOIN CI_MIDDLEWAY..mw_meio_pagamento_forma_pagamento mpfp ON mp.id_meio_pagamento=mpfp.id_meio_pagamento AND mpfp.id_base=@id_base
LEFT JOIN #data_bases db ON mpfp.CodForPagto=db.CodForPagto
WHERE in_ativo=1
ORDER BY mp.ds_meio_pagamento
