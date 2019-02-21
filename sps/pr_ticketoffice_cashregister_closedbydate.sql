ALTER PROCEDURE dbo.pr_ticketoffice_cashregister_closedbydate (
        @id_base INT
        ,@id_ticketoffice_user UNIQUEIDENTIFIER
        ,@date VARCHAR(100)
        )

AS

-- DECLARE @id_ticketoffice_user UNIQUEIDENTIFIER = 'f2177e5e-f727-4906-948d-4eea9b9bbd0e'
--         , @date VARCHAR(100) = '21/02/2019'

SELECT
tocr.id
,CONVERT(VARCHAR(10),tocr.created,103) + ' ' + CONVERT(VARCHAR(8),tocr.created,114) AS created
,CONVERT(VARCHAR(10),tocr.closed,103) + ' ' + CONVERT(VARCHAR(8),tocr.closed,114) AS closed
,tocr.justification_closed
,tau.name
,tau.[login]
,tau.email
FROM CI_MIDDLEWAY..ticketoffice_cashregister tocr
INNER JOIN CI_MIDDLEWAY..to_admin_user tau ON tocr.id_ticketoffice_user_closed=tau.id
WHERE
CONVERT(VARCHAR(10),tocr.closed,103)=@date
AND tocr.id_ticketoffice_user=@id_ticketoffice_user
AND isopen=0
AND tocr.id_base=@id_base