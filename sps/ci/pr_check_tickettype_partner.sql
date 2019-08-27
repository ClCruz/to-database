-- exec sp_executesql N'EXEC pr_check_tickettype_partner @P1,@P2',N'@P1 int,@P2 varchar(8000)',6,'live_ad7750c9491a41b7bd2fed3b0d03a8f44613d2c3b20d4435b6e7f2b67881d34c'
-- exec sp_executesql N'EXEC pr_check_tickettype_partner @P1,@P2',N'@P1 varchar(8000),@P2 int','live_ad7750c9491a41b7bd2fed3b0d03a8f44613d2c3b20d4435b6e7f2b67881d34c',6
-- exec sp_executesql N'EXEC pr_check_tickettype_partner @P1,@P2',N'@P1 varchar(8000),@P2 int','live_ad7750c9491a41b7bd2fed3b0d03a8f44613d2c3b20d4435b6e7f2b67881d34c',1

-- select * from CI_MIDDLEWAY..tickettype_partner
ALTER PROCEDURE dbo.pr_check_tickettype_partner (@api VARCHAR(100), @CodTipBilhete INT)

AS

-- DECLARE @api VARCHAR(100) = 'live_3d45ca13d9a6408abb594ceb30d8d56e441fb74dc16d4301aa5537f15ab1b543' --live_ad7750c9491a41b7bd2fed3b0d03a8f44613d2c3b20d4435b6e7f2b67881d34c
--         ,@CodTipBilhete INT = 6

SET NOCOUNT ON;
DECLARE @id_base INT
        ,@id_partner UNIQUEIDENTIFIER

SELECT TOP 1 @id_partner=p.id FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api

SELECT @id_base = id_base FROM ci_middleway..mw_base WHERE ds_nome_base_sql = DB_NAME()

SELECT
(CASE WHEN tb.allpartner = 1 OR tb.allpartner IS NULL THEN 1 ELSE ISNULL(ttp.active,0) END) active
FROM tabTipBilhete tb
LEFT JOIN CI_MIDDLEWAY..tickettype_partner ttp ON ttp.CodTipBilhete=tb.CodTipBilhete AND ttp.id_base=@id_base AND ttp.id_partner=@id_partner
WHERE tb.CodTipBilhete=@CodTipBilhete
