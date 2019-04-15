-- exec sp_executesql N'EXEC pr_pinpad_update @P1,@P2,@P3,@P4,@P5,@P6,@P7,@P8',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000),@P7 nvarchar(4000),@P8 nvarchar(4000)',N'B23C243A49684A9DBD6730AAA5958563',N'0000',N'6191130',N'1',N'0',N'0',N'1',N'0'
--exec sp_executesql N'EXEC pr_pinpad_update @P1,@P2,@P3,@P4,@P5,@P6,@P7,@P8',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000),@P7 nvarchar(4000),@P8 nvarchar(4000)',N'9BE771FE88C641E5AB1EB88F4E782EB9',N'0000',N'6191154',N'1',N'0',N'0',N'1',N'0'
-- select * from ticketoffice_gateway_result

-- select top 100 * from CI_MIDDLEWAY..ticketoffice_pinpad order by created desc
ALTER PROCEDURE dbo.pr_pinpad_update (@key VARCHAR(50),@pinpad_acquirerResponseCode VARCHAR(100),@pinpad_transactionId VARCHAR(100)
                                    ,@pinpad_executed BIT,@pinpad_error BIT,@pinpad_cancel BIT
                                    ,@pinpad_ok BIT,@pinpad_fail BIT,@codVenda VARCHAR(10))

AS

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
WHERE [key]=@key

INSERT INTO CI_MIDDLEWAY..ticketoffice_gateway_result (id_ticketoffice_user, id_ticketoffice_shoppingcart, transactionKey, id_gateway)
SELECT TOP 1 topp.id_ticketoffice_user, tosc.id, topp.pinpad_transactionId, 6
FROM CI_MIDDLEWAY..ticketoffice_pinpad topp
INNER JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosc ON topp.codVenda=tosc.codVenda
WHERE [key]=@key