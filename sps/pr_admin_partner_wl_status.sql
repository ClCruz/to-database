ALTER PROCEDURE pr_admin_partner_wl_status (@id_partner UNIQUEIDENTIFIER = NULL
        ,@uniquename VARCHAR(500) = NULL
        ,@type VARCHAR(100) = NULL
        ,@status VARCHAR(100) = NULL)

AS

-- DECLARE @id_partner UNIQUEIDENTIFIER
--         ,@uniquename VARCHAR(500)
--         ,@type VARCHAR(100)
--         ,@status VARCHAR(100)


SET NOCOUNT ON;

DECLARE @idofconf UNIQUEIDENTIFIER
        ,@hasConf BIT = 0
        ,@hasJob BIT = 0


IF @uniquename IS NULL
BEGIN
    SELECT @uniquename=uniquename 
    FROM CI_MIDDLEWAY..[partner]
    WHERE id=@id_partner
END
IF @id_partner IS NULL
BEGIN
    SELECT @id_partner=id 
    FROM CI_MIDDLEWAY..[partner]
    WHERE uniquename=@uniquename
END


SELECT @idofconf=id
        ,@hasConf=1
FROM CI_MIDDLEWAY..whitelabelconf wlc
WHERE wlc.id_partner=@id_partner
--AND wlc.[status]=@status
AND wlc.[type]=@type

IF @hasConf = 1
BEGIN
    UPDATE CI_MIDDLEWAY..whitelabelconf 
        SET [status]=@status
    WHERE id=@idofconf
END
ELSE
BEGIN
    INSERT INTO CI_MIDDLEWAY..whitelabelconf(uniquename,id_partner,[type],[status]) VALUES (@uniquename, @id_partner, @type, @status)
END

IF @status = 'init' AND @type = 'database'
BEGIN
    DECLARE @has BIT = 0
    SELECT @has = 1 FROM CI_MIDDLEWAY..whitelabeljob WHERE uniquename=@uniquename
    IF @has = 0
    BEGIN
        INSERT INTO CI_MIDDLEWAY..whitelabeljob (uniquename) VALUES (@uniquename)
    END
END