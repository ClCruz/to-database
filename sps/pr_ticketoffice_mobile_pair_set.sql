ALTER PROCEDURE dbo.pr_ticketoffice_mobile_pair_set (@code VARCHAR(100), @device VARCHAR(100))

AS

SET NOCOUNT ON;

DECLARE @has BIT = 0

SELECT @has = 1 FROM CI_MIDDLEWAY..ticketoffice_pairdevice topd WHERE topd.code=@code

IF @has = 1
BEGIN
    UPDATE d
    SET d.isPaired = 1
        ,d.deviceid=@device
        ,d.updated=GETDATE()
    FROM CI_MIDDLEWAY..ticketoffice_pairdevice d
    WHERE code=@code

    SELECT TOP 1
        topd.id
        ,topd.id_ticketoffice_user
        ,topd.deviceid
        ,topd.isPaired
        ,topd.unpair
        ,topd.updated
        ,tau.[login]
        ,tau.name
        ,tau.email
        ,1 success
        ,'' msg
    FROM CI_MIDDLEWAY..ticketoffice_pairdevice topd
    INNER JOIN CI_MIDDLEWAY..to_admin_user tau ON topd.id_ticketoffice_user=tau.id
    WHERE topd.code=@code
    RETURN;
END

SELECT 0 success
        ,'Não foi possível achar o código informado.' msg
        , '' id
        , '' id_ticketoffice_user
        , '' deviceid
        , 0 isPaired
        , 0 unpair
        , '' updated
        , '' [login]
        , '' [name]
        , '' email