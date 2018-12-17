
CREATE PROCEDURE dbo.pr_producer_save (@api VARCHAR(100), @id VARCHAR(100), @name VARCHAR(1000), @login VARCHAR(1000), @email VARCHAR(1000), @document VARCHAR(50), @active BIT, @newPass VARCHAR(1000))

AS 

SET NOCOUNT ON;

-- DECLARE @api VARCHAR(100) = 'live_keykeykey', @id VARCHAR(100) = '', @name VARCHAR(1000)='teste', @login VARCHAR(1000)= 'teste', @email VARCHAR(1000)='teste@teste.com', @active BIT = 1, @newPass VARCHAR(1000) = '56f4485c63c0ef77d158f4739d4a4025148e1091'

DECLARE @hasAnotherWithLogin BIT = 0
        ,@has BIT = 0
        ,@idAux UNIQUEIDENTIFIER = NULL

IF @id IS NOT NULL AND @id != ''
    SET @idAux = @id

SELECT TOP 1 @hasAnotherWithLogin=1 FROM CI_MIDDLEWAY..producer WHERE LOWER([login])=RTRIM(LTRIM(LOWER(@login))) AND id!=@idAux
SELECT TOP 1 @has=1 FROM CI_MIDDLEWAY..producer WHERE id=@idAux

IF @hasAnotherWithLogin = 1
BEGIN
    SELECT 0 success
            ,'Já há outro produtor com esse login.' msg

    RETURN;
END

IF @has = 1
BEGIN
    UPDATE CI_MIDDLEWAY..producer SET [login]=@login, [name]=@name, email=@email, document=@document, active=@active, updated=GETDATE() WHERE id=@idAux
END
ELSE
BEGIN
    INSERT INTO CI_MIDDLEWAY..producer (updated,[login],[password],lastLogin,[name],email, document,active,currentToken,tokenValidUntil)
    SELECT GETDATE(),@login,@newPass, NULL, @name, @email, @document, 1, NULL, NULL
END

SELECT 1 success
        ,'' msg