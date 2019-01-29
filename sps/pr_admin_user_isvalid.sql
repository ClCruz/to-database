
ALTER PROCEDURE pr_admin_user_isvalid(@id UNIQUEIDENTIFIER)

AS


SET NOCOUNT ON;

DECLARE @hasUser BIT = 0
        ,@valid BIT = 0

SELECT
    @hasUser = 1
    ,@valid = (CASE WHEN currentToken = '' OR currentToken IS NULL THEN 0 ELSE
    (CASE WHEN tokenValidUntil >=GETDATE() THEN 1 ELSE 0 END) END)
FROM CI_MIDDLEWAY..to_admin_user
WHERE id=@id

SELECT @hasUser hasuser
        ,@valid valid