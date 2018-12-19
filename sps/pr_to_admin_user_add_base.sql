
ALTER PROCEDURE pr_to_admin_user_add_base (@id_user UNIQUEIDENTIFIER, @id UNIQUEIDENTIFIER, @id_base INT, @id_evento INT = NULL)

AS

SET NOCOUNT ON;

DECLARE @has BIT = 0
        ,@hasActive BIT = 0 

SELECT TOP 1 @has = 1, @hasActive = active FROM CI_MIDDLEWAY..to_admin_user_base WHERE id_to_admin_user=@id AND id_base=@id_base AND (@id_evento IS NULL OR id_evento=@id_evento)

IF @has = 1
BEGIN
    IF @hasActive = 1
    BEGIN
        UPDATE CI_MIDDLEWAY..to_admin_user_base SET active=0, updated = GETDATE(), updatedby=@id_user WHERE id_to_admin_user=@id AND id_base=@id_base AND (@id_evento IS NULL OR id_evento=@id_evento)
    END
    ELSE
    BEGIN
        UPDATE CI_MIDDLEWAY..to_admin_user_base SET active=1, updated = GETDATE(), updatedby=@id_user WHERE id_to_admin_user=@id AND id_base=@id_base AND (@id_evento IS NULL OR id_evento=@id_evento)
    END

    SELECT 1 success
        ,'' msg
    
    RETURN;
END

INSERT INTO CI_MIDDLEWAY..to_admin_user_base (id_to_admin_user, id_base, id_evento, createdby)
SELECT @id, @id_base, @id_evento, @id_user


SELECT 1 success
        ,'' msg
