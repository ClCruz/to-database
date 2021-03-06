ALTER PROCEDURE dbo.pr_to_admin_user_save (@api VARCHAR(100), @id VARCHAR(100), @name VARCHAR(1000), @login VARCHAR(1000), @email VARCHAR(1000), @document VARCHAR(50), @active BIT, @newPass VARCHAR(1000), @changePass BIT = 0)

AS 

SET NOCOUNT ON;

DECLARE @hasAnotherWithLogin BIT = 0
        ,@has BIT = 0
        ,@hasTicketoffice BIT = 0
        ,@idAux UNIQUEIDENTIFIER = NULL

IF @id IS NOT NULL AND @id != ''
    SET @idAux = @id

SELECT TOP 1 @hasAnotherWithLogin=1 FROM CI_MIDDLEWAY..to_admin_user WHERE LOWER([login])=RTRIM(LTRIM(LOWER(@login))) AND (@idAux IS NULL OR id!=@idAux)
SELECT TOP 1 @has=1 FROM CI_MIDDLEWAY..to_admin_user WHERE id=@idAux
SELECT TOP 1 @hasTicketoffice=1 FROM CI_MIDDLEWAY..ticketoffice_user WHERE id=@idAux

IF @hasAnotherWithLogin = 1
BEGIN
    SELECT 0 success
            ,'Já há outro usuário com esse login.' msg
    RETURN;
END



IF @has = 1
BEGIN
    UPDATE CI_MIDDLEWAY..to_admin_user SET [login]=@login, [name]=@name, email=@email, document=@document, active=@active, updated=GETDATE() WHERE id=@idAux
END
ELSE
BEGIN
    SET @idAux = NEWID();
    INSERT INTO CI_MIDDLEWAY..to_admin_user (id, updated,[login],[password],lastLogin,[name],email, document,active,currentToken,tokenValidUntil)
    SELECT @idAux, GETDATE(),@login,@newPass, NULL, @name, @email, @document, 1, NULL, NULL
END

IF @hasTicketoffice = 1
BEGIN
    UPDATE CI_MIDDLEWAY..ticketoffice_user SET [login]=@login, [name]=@name, email=@email, active=@active, updated=GETDATE() WHERE id=@idAux    
END
ELSE
BEGIN
    INSERT INTO CI_MIDDLEWAY..ticketoffice_user (id, updated,[login],[password],lastLogin,[name],email,active)
    SELECT @idAux, GETDATE(),@login,@newPass, NULL, @name, @email, 1
END

UPDATE CI_MIDDLEWAY..ticketoffice_user SET active=0 WHERE [login]=@login AND active=1 AND id!=@idAux

IF @changePass = 1
BEGIN
    UPDATE CI_MIDDLEWAY..to_admin_user SET [password]=@newPass WHERE id=@idAux
END

SELECT 1 success
        ,'' msg