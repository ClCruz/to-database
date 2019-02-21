ALTER PROCEDURE dbo.pr_ticketoffice_cashregister_opendate (@id_ticketoffice_user UNIQUEIDENTIFIER
        ,@id_base INT)


AS


SET NOCOUNT ON;
-- DECLARE @id_ticketoffice_user UNIQUEIDENTIFIER = 'f2177e5e-f727-4906-948d-4eea9b9bbd0e'
--         ,@id_base INT = 213

DECLARE @lastDateOpen VARCHAR(100)
        ,@has BIT = 0

SELECT @has=1,@lastdateOpen = CONVERT(VARCHAR(10),created,103) + ' ' + CONVERT(VARCHAR(8),created,114) FROM CI_MIDDLEWAY..ticketoffice_cashregister WHERE id_ticketoffice_user=@id_ticketoffice_user AND id_base=@id_base AND isopen=1 ORDER BY created

IF @has = 0
    SET @lastDateOpen = 'Sem abertura de caixa'

SELECT @lastDateOpen opendate