--exec pr_adm_ticketoffice_users @perPage=1, @currentPage=10

CREATE PROCEDURE dbo.pr_adm_ticketoffice_users_get (@id UNIQUEIDENTIFIER)

AS

SELECT
    tou.id
    ,tou.name
    ,tou.[login]
    ,tou.email
    ,tou.active
    ,CONVERT(VARCHAR(10),tou.created,103) + ' ' + CONVERT(VARCHAR(8),tou.created,114) [created]
    ,CONVERT(VARCHAR(10),tou.updated,103) + ' ' + CONVERT(VARCHAR(8),tou.updated,114) [updated]
FROM CI_MIDDLEWAY..ticketoffice_user tou
WHERE 
    tou.id=@id