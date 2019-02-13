CREATE PROCEDURE dbo.pr_admin_user_mobile_pair_generate (@id UNIQUEIDENTIFIER)

AS

SET NOCOUNT ON;

DECLARE @has BIT = 0
        ,@idOK BIT = 0
        ,@code VARCHAR(5)
        ,@keepLoop BIT = 1

WHILE (@keepLoop = 1)
BEGIN  
    SELECT @code = RIGHT('00000' + CONVERT(VARCHAR(100),FLOOR(RAND()*(99999-00000+1))+10), 5)

    DECLARE @codeOK BIT = 1
    SELECT @codeOK = 0 FROM CI_MIDDLEWAY..ticketoffice_pairdevice WHERE code=@code

    IF @codeOK = 1
        SET @keepLoop = 0
END


SELECT @idOK=1 FROM CI_MIDDLEWAY..to_admin_user sub WHERE sub.id=@id

IF @idOK = 1
BEGIN
    SELECT @has = 1 FROM CI_MIDDLEWAY..ticketoffice_pairdevice sub WHERE sub.id_ticketoffice_user=@id


    DECLARE @codeOK2 BIT = 1
    SELECT @codeOK2 = 0 FROM CI_MIDDLEWAY..ticketoffice_pairdevice WHERE code=@code

    IF @codeOK2 = 0
    BEGIN
        SELECT 0 success
                ,'Não foi possível gerar o código, por favor tente novamente' msg
        RETURN;
    END


    IF @has = 1
    BEGIN
        UPDATE d
        SET d.code = @code
            ,d.updated=GETDATE()
        FROM CI_MIDDLEWAY..ticketoffice_pairdevice d
        WHERE d.id_ticketoffice_user=@id
    END
    ELSE
    BEGIN
        INSERT INTO CI_MIDDLEWAY..ticketoffice_pairdevice(code,deviceid,id_ticketoffice_user,isPaired,unpair,updated)
            SELECT @code, NULL, @id, 0, 0, GETDATE()
    END
END


SELECT 1 success
        ,@code msg
RETURN;
