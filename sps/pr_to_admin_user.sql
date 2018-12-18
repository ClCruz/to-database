
CREATE PROCEDURE dbo.pr_to_admin_user (@api VARCHAR(100) = NULL)

AS

SET NOCOUNT ON;

SELECT
    tau.id
    ,tau.active
    ,tau.document
    ,tau.email
    ,tau.[login]
    ,tau.name
    ,CONVERT(VARCHAR(10),tau.lastLogin,103) + ' ' + CONVERT(VARCHAR(8),tau.lastLogin,114) [lastLogin]
    ,CONVERT(VARCHAR(10),tau.created,103) + ' ' + CONVERT(VARCHAR(8),tau.created,114) [created]
    ,CONVERT(VARCHAR(10),tau.updated,103) + ' ' + CONVERT(VARCHAR(8),tau.updated,114) [updated]
FROM CI_MIDDLEWAY..to_admin_user tau
ORDER by tau.name