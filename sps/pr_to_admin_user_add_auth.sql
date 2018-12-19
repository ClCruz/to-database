
ALTER PROCEDURE pr_to_admin_user_add_auth (@id_user UNIQUEIDENTIFIER, @id UNIQUEIDENTIFIER, @id_auth UNIQUEIDENTIFIER)

AS

SET NOCOUNT ON;

DECLARE @has BIT = 0
        ,@hasActive BIT = 0 

SELECT TOP 1 @has = 1, @hasActive = active FROM CI_MIDDLEWAY..to_admin_authorization_user WHERE id_admin_user=@id AND id_admin_authorization=@id_auth

IF @has = 1
BEGIN
    IF @hasActive = 1
    BEGIN
        UPDATE CI_MIDDLEWAY..to_admin_authorization_user SET active=0, updated=GETDATE(), updatedby=@id_user WHERE id_admin_user=@id AND id_admin_authorization=@id_auth
    END
    ELSE
    BEGIN
        UPDATE CI_MIDDLEWAY..to_admin_authorization_user SET active=1, updated=GETDATE(), updatedby=@id_user WHERE id_admin_user=@id AND id_admin_authorization=@id_auth
    END

    SELECT 1 success
        ,'' msg
    
    RETURN;
END

INSERT INTO CI_MIDDLEWAY..to_admin_authorization_user (id_admin_user, id_admin_authorization, active, createdby)
SELECT @id, @id_auth, 1, @id_user


SELECT 1 success
        ,'' msg
