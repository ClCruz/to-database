-- pr_ticketoffice_user_add_base '8CC26A74-7E65-411E-B854-F7B281A46E01'
-- exec sp_executesql N'EXEC pr_ticketoffice_user_add_base @P1',N'@P1 nvarchar(4000)',N'8CC26A74-7E65-411E-B854-F7B281A46E01'
-- select * from CI_MIDDLEWAY..ticketoffice_user_base
-- exec sp_executesql N'EXEC pr_ticketoffice_user_base_list @P1',N'@P1 nvarchar(4000)',N'93B93F5D-133A-4464-A57F-3C532BB33C59'
GO
CREATE PROCEDURE pr_producer_add_base (@id UNIQUEIDENTIFIER, @id_base INT, @id_evento INT = NULL)

AS

SET NOCOUNT ON;

DECLARE @has BIT = 0
        ,@hasActive BIT = 0 

SELECT TOP 1 @has = 1, @hasActive = active FROM CI_MIDDLEWAY..producer_base WHERE id_producer=@id AND id_base=@id_base AND (@id_evento IS NULL OR id_evento=@id_evento)

IF @has = 1
BEGIN
    IF @hasActive = 1
    BEGIN
        UPDATE CI_MIDDLEWAY..producer_base SET active=0 WHERE id_producer=@id AND id_base=@id_base AND (@id_evento IS NULL OR id_evento=@id_evento)
    END
    ELSE
    BEGIN
        UPDATE CI_MIDDLEWAY..producer_base SET active=1 WHERE id_producer=@id AND id_base=@id_base AND (@id_evento IS NULL OR id_evento=@id_evento)
    END

    SELECT 1 success
        ,'' msg
    
    RETURN;
END

INSERT INTO CI_MIDDLEWAY..producer_base (id_producer, id_base, id_evento)
SELECT @id, @id_base, @id_evento


SELECT 1 success
        ,'' msg
