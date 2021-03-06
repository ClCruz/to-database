ALTER PROCEDURE dbo.pr_ticketoffice_user_add(@login VARCHAR(1000), @name VARCHAR(1000), @password VARCHAR(1000), @email VARCHAR(1000))

AS

SET NOCOUNT ON;

SET @login=lower(RTRIM(LTRIM(@login)));
SET @name=RTRIM(LTRIM(@name));
SET @email=RTRIM(LTRIM(@email));

DECLARE @exist BIT = 0
        ,@added BIT = 0
        ,@id UNIQUEIDENTIFIER = NULL

SELECT
@exist=1
FROM CI_MIDDLEWAY..ticketoffice_user tou
WHERE lower(tou.login)=lower(@login) AND tou.active=1

IF @exist IS NULL OR @exist = 0
BEGIN
    SET @id = NEWID();

    INSERT INTO CI_MIDDLEWAY..ticketoffice_user([id],[login],[password],[name],[email],[active])
    VALUES(@id, @login, @password, @name, @email, 1);
    SET @added=1;
END

SELECT
    @added added
    ,@id id