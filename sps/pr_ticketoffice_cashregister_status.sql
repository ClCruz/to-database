ALTER PROCEDURE dbo.pr_ticketoffice_cashregister_status (@id_ticketoffice_user UNIQUEIDENTIFIER, @id_base INT)

AS

-- DECLARE @id_ticketoffice_user UNIQUEIDENTIFIER = 'f2177e5e-f727-4906-948d-4eea9b9bbd0e'
--         , @id_base INT = 213

SET NOCOUNT ON;

DECLARE @has BIT = 0
        ,@canOpen BIT = 0
        ,@created DATETIME = NULL
        ,@hoursopen INT = 0
        ,@hoursopenMax INT = 24
        ,@needclose BIT = 0

SELECT @has=1,@created=created FROM CI_MIDDLEWAY..ticketoffice_cashregister WHERE id_ticketoffice_user=@id_ticketoffice_user AND id_base=@id_base AND isopen=1



IF @has = 1
BEGIN
    SELECT @hoursopen = datediff(hh, @created, getdate())

    IF (@hoursopen>=@hoursopenMax)
    BEGIN
        SET @needclose = 1
    END

    SELECT 1 success
            ,1 isopen
            ,@needclose needclose
            ,@hoursopen openhours
    RETURN;
END

SELECT 1 success
        ,0 isopen
        ,@needclose needclose
        ,@hoursopen openhours