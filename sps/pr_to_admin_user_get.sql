--exec pr_adm_ticketoffice_users @perPage=1, @currentPage=10

ALTER PROCEDURE dbo.pr_to_admin_user_get (@id UNIQUEIDENTIFIER)

AS

SET NOCOUNT ON;

SELECT TOP 1
    tau.id
    ,tau.active
    ,tau.document
    ,tau.email
    ,tau.[login]
    ,tau.name
    ,CONVERT(VARCHAR(10),tau.lastLogin,103) + ' ' + CONVERT(VARCHAR(8),tau.lastLogin,114) [lastLogin]
    ,CONVERT(VARCHAR(10),tau.created,103) + ' ' + CONVERT(VARCHAR(8),tau.created,114) [created]
    ,CONVERT(VARCHAR(10),tau.updated,103) + ' ' + CONVERT(VARCHAR(8),tau.updated,114) [updated]
    ,(SELECT TOP 1 sub.code FROM CI_MIDDLEWAY..ticketoffice_pairdevice sub WHERE sub.id_ticketoffice_user=tau.id ORDER BY sub.created DESC) pair
FROM CI_MIDDLEWAY..to_admin_user tau
WHERE id=@id