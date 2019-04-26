
ALTER PROCEDURE dbo.pr_admin_partner_save 
    (@loggedId UNIQUEIDENTIFIER
    ,@id UNIQUEIDENTIFIER
    ,@uniquename VARCHAR(500)
    ,@name VARCHAR(1000)
    ,@domain VARCHAR(1000)
    ,@dateStart DATETIME
    ,@dateEnd DATETIME
    ,@type VARCHAR(100)
    ,@active BIT
    ,@fb_appid VARCHAR(1000) = NULL
    ,@recaptchaid VARCHAR(1000) = NULL
    ,@sell_email VARCHAR(1000) = NULL
    ,@send_sell_email BIT = 0
    ,@ga_id VARCHAR(1000) = NULL)

AS

-- DECLARE @loggedId UNIQUEIDENTIFIER
--     ,@id UNIQUEIDENTIFIER
--     ,@name VARCHAR(1000)
--     ,@domain VARCHAR(1000)
--     ,@dateStart DATETIME
--     ,@dateEnd DATETIME
--     ,@type VARCHAR(100)
--     ,@active BIT

-- select @loggedId = N'F2177E5E-F727-4906-948D-4EEA9B9BBD0E'
-- , @id=N'00000000-0000-0000-0000-000000000000'
-- ,@name=N'teste'
-- ,@domain=N'tested'
-- ,@dateStart=N'2019-01-17'
-- ,@dateEnd=N'2019-01-18'
-- ,@type=N'trial'
-- ,@active=N'1'

SET NOCOUNT ON;

DECLARE @has BIT = 0;

IF @id != '00000000-0000-0000-0000-000000000000'
BEGIN
    SELECT @has = 1 FROM CI_MIDDLEWAY..[partner] WHERE id=@id;
END

IF @dateEnd<='1900-01-01 00:00:00.000'
    SET @dateEnd=NULL

DECLARE @isDemo BIT = 0
        ,@isTrial BIT = 0
        ,@isDev BIT = 0
        ,@key VARCHAR(100)
        ,@key_test VARCHAR(100)

IF @type = 'prod'
BEGIN
    SELECT @isDemo=0
            ,@isTrial=0
            ,@isDev=0
END
IF @type = 'demo'
BEGIN
    SELECT @isDemo=1
            ,@isTrial=0
            ,@isDev=0
END
IF @type = 'trial'
BEGIN
    SELECT @isDemo=0
            ,@isTrial=1
            ,@isDev=0
END
IF @type = 'dev'
BEGIN
    SELECT @isDemo=0
            ,@isTrial=0
            ,@isDev=1
END

IF @has = 1
BEGIN
    
    UPDATE CI_MIDDLEWAY..[partner]
        SET [name]=@name
            ,domain=@domain
            ,dateStart=@dateStart
            ,dateEnd=@dateEnd
            ,isDemo=@isDemo
            ,isTrial=@isTrial
            ,isDev=@isDev
            ,fb_appid=@fb_appid
            ,recaptchaid=@recaptchaid
            ,send_sell_email=@send_sell_email
            ,sell_email=@sell_email
            ,ga_id=@ga_id
    WHERE
        id=@id

    SELECT 1 success
            ,'Alterado com sucesso.' msg

    RETURN;
END
ELSE
BEGIN

    DECLARE @hasUniqueName BIT = 0;

    SET @uniquename=lower(@uniquename);

    SELECT @hasUniqueName = 1 FROM CI_MIDDLEWAY..[partner] WHERE LOWER(uniquename)=@uniquename

    IF @hasUniqueName = 1
    BEGIN
        SELECT 0 success
                ,'Nome único já existente.' msg

        RETURN;
    END

    IF OBJECT_ID('tempdb.dbo.#keypartner', 'U') IS NOT NULL
        DROP TABLE #keypartner; 

    CREATE TABLE #keypartner ([key] VARCHAR(100), [key_test] VARCHAR(100));

    INSERT INTO #keypartner EXEC CI_MIDDLEWAY..pr_partner_key NULL, 0;

    SELECT @key=[key], @key_test=key_test FROM #keypartner

    INSERT INTO CI_MIDDLEWAY..[partner] ([key], key_test, [name], active, dateStart, dateEnd, domain, uniquename,fb_appid,recaptchaid,sell_email,send_sell_email,ga_id)
     VALUES (@key, @key_test, @name, @active, @dateStart, @dateEnd, @domain, @uniquename,@fb_appid,@recaptchaid,@sell_email,@send_sell_email,@ga_id)

    SELECT 1 success
            ,'Incluido com sucesso.' msg

    RETURN;

END