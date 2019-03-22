ALTER PROCEDURE dbo.pr_to_admin_user_changepass (@id UNIQUEIDENTIFIER
        ,@oldpass VARCHAR(1000)
        ,@newpass VARCHAR(1000))

AS
-- DECLARE @id UNIQUEIDENTIFIER = 'f2177e5e-f727-4906-948d-4eea9b9bbd0e'
--         ,@oldpass VARCHAR(1000)
--         ,@newpass VARCHAR(1000)

SET NOCOUNT ON;

DECLARE @pass VARCHAR(1000)

SELECT @pass = toau.[password]
FROM CI_MIDDLEWAY..to_admin_user toau
WHERE toau.id=@id

IF @pass = @oldpass
BEGIN
    UPDATE CI_MIDDLEWAY..to_admin_user SET [password]=@newpass, updated=GETDATE() WHERE id=@id

    SELECT 1 success
            ,'Senha alterada com sucesso' msg
    RETURN;
END

SELECT 0 success
        ,'Por favor verifique sua antiga senha' msg