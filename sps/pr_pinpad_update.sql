--exec sp_executesql N'EXEC pr_pinpad_update @P1,@P2,@P3,@P4,@P5,@P6,@P7,@P8,@P9',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000),@P7 nvarchar(4000),@P8 nvarchar(4000),@P9 nvarchar(4000)',N'33067F4CC9EE44039009A04D65C690F7',N'0000',N'6785166',N'1',N'0',N'0',N'1',N'0',N'IMIOIGDHAI'

-- select top 100 * from CI_MIDDLEWAY..ticketoffice_pinpad order by created desc
ALTER PROCEDURE dbo.pr_pinpad_update (@key VARCHAR(50),@pinpad_acquirerResponseCode VARCHAR(100),@pinpad_transactionId VARCHAR(100)
                                    ,@pinpad_executed BIT,@pinpad_error BIT,@pinpad_cancel BIT
                                    ,@pinpad_ok BIT,@pinpad_fail BIT,@codVenda VARCHAR(10),@bin VARCHAR(10) = NULL)

AS

-- DECLARE @key VARCHAR(50) = '33067F4CC9EE44039009A04D65C690F7'
--         ,@pinpad_acquirerResponseCode VARCHAR(100) = '0000'
--         ,@pinpad_transactionId VARCHAR(100) = '6785166'
--         ,@pinpad_executed BIT = 1
--         ,@pinpad_error BIT = 0
--         ,@pinpad_cancel BIT = 0
--         ,@pinpad_ok BIT = 1
--         ,@pinpad_fail BIT = 0
--         ,@codVenda VARCHAR(10) = 'IMIOIGDHAI'
--         ,@bin VARCHAR(10) = NULL


-- select * from ticketoffice_pinpad where [key]=@key
SET NOCOUNT ON;

UPDATE CI_MIDDLEWAY..ticketoffice_pinpad
SET
pinpad_acquirerResponseCode=@pinpad_acquirerResponseCode
,pinpad_transactionId=@pinpad_transactionId
,pinpad_executed=@pinpad_executed
,pinpad_error=@pinpad_error
,pinpad_cancel=@pinpad_cancel
,pinpad_ok=@pinpad_ok
,pinpad_fail=@pinpad_fail
,codVenda=@codVenda
,bin=@bin
WHERE [key]=@key

INSERT INTO CI_MIDDLEWAY..ticketoffice_gateway_result (id_ticketoffice_user, id_ticketoffice_shoppingcart, transactionKey, id_gateway)
SELECT TOP 1 topp.id_ticketoffice_user, tosc.id, topp.pinpad_transactionId, 6
FROM CI_MIDDLEWAY..ticketoffice_pinpad topp
INNER JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosc ON topp.codVenda=tosc.codVenda
LEFT JOIN CI_MIDDLEWAY..ticketoffice_gateway_result togr ON topp.pinpad_transactionId=togr.transactionKey AND togr.id_gateway=6
WHERE [key]=@key AND togr.id IS NULL


DECLARE @id_base INT
        ,@db_name VARCHAR(1000)
        ,@toExec NVARCHAR(MAX) = ''
        ,@StaCadeira VARCHAR(1) = 'V'

SELECT @id_base = tosc.id_base,@db_name=b.ds_nome_base_sql
FROM CI_MIDDLEWAY..ticketoffice_pinpad topp
INNER JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosc ON topp.codVenda=tosc.codVenda
INNER JOIN CI_MIDDLEWAY..mw_base b ON tosc.id_base=b.id_base
WHERE [key]=@key

SET @toExec=''
SET @toExec = @toExec+' UPDATE ['+@db_name+'].dbo.tabLugSala'
SET @toExec = @toExec+' SET BINCartao=@bin'
SET @toExec = @toExec+' WHERE CodVenda=@codVenda AND StaCadeira=@StaCadeira'
EXEC sp_executesql @toExec, N'@bin VARCHAR(100), @codVenda VARCHAR(100), @StaCadeira VARCHAR(1)',@bin,@codVenda,@StaCadeira

