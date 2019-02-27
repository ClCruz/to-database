ALTER PROCEDURE dbo.pr_ticketoffice_cashregister_closedbydate (
        @id_base INT
        ,@id_ticketoffice_user UNIQUEIDENTIFIER
        ,@date VARCHAR(100)
        ,@id UNIQUEIDENTIFIER
        )

AS

-- DECLARE @id_base INT = 213
--         ,@id_ticketoffice_user UNIQUEIDENTIFIER = 'F2177E5E-F727-4906-948D-4EEA9B9BBD0E'
--         ,@date VARCHAR(100) = ''
--         ,@id UNIQUEIDENTIFIER = 'C59F097E-CC57-4E62-A9C7-C555C7ECB44A'


IF @id = '00000000-0000-0000-0000-000000000000'
    SET @id = NULL

SELECT
tocr.id
,CONVERT(VARCHAR(10),tocr.created,103) + ' ' + CONVERT(VARCHAR(8),tocr.created,114) AS created
,CONVERT(VARCHAR(10),tocr.closed,103) + ' ' + CONVERT(VARCHAR(8),tocr.closed,114) AS closed
,tocr.justification_closed
,tau.name
,tau.[login]
,tau.email
,ISNULL((SELECT TOP 1 1 FROM CI_MIDDLEWAY..ticketoffice_cashregister_moviment sub WHERE sub.id_ticketoffice_cashregister=tocr.id AND [type]='diff' AND amount!=0),0) hasDiff
FROM CI_MIDDLEWAY..ticketoffice_cashregister tocr
INNER JOIN CI_MIDDLEWAY..to_admin_user tau ON tocr.id_ticketoffice_user_closed=tau.id
WHERE
tocr.id_ticketoffice_user=@id_ticketoffice_user
AND isopen=0
AND tocr.id_base=@id_base
AND (@id IS NULL OR tocr.id=@id)
AND (@id IS NOT NULL OR CONVERT(VARCHAR(10),tocr.closed,103)=@date)