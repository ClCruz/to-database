
CREATE PROCEDURE dbo.pr_to_admin_user_resetpass (@api VARCHAR(100), @id UNIQUEIDENTIFIER, @newPass VARCHAR(1000))

AS 

SET NOCOUNT ON;

UPDATE CI_MIDDLEWAY..to_admin_user SET [password]=@newPass, updated=GETDATE() WHERE id=@id

SELECT 1 success
        ,'' msg