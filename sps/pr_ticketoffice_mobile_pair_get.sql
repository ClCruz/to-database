ALTER PROCEDURE dbo.pr_ticketoffice_mobile_pair_get (@code VARCHAR(100))

AS

SELECT TOP 1
    topd.id
    ,topd.id_ticketoffice_user
    ,topd.deviceid
    ,topd.isPaired
    ,topd.unpair
    ,topd.updated
FROM CI_MIDDLEWAY..ticketoffice_pairdevice topd
WHERE topd.code=@code