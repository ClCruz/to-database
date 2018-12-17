
CREATE PROCEDURE dbo.pr_producer (@api VARCHAR(100) = NULL)

AS

SET NOCOUNT ON;

SELECT
    p.id
    ,p.active
    ,p.document
    ,p.email
    ,p.[login]
    ,p.name
    ,CONVERT(VARCHAR(10),p.lastLogin,103) + ' ' + CONVERT(VARCHAR(8),p.lastLogin,114) [lastLogin]
    ,CONVERT(VARCHAR(10),p.created,103) + ' ' + CONVERT(VARCHAR(8),p.created,114) [created]
    ,CONVERT(VARCHAR(10),p.updated,103) + ' ' + CONVERT(VARCHAR(8),p.updated,114) [updated]
FROM CI_MIDDLEWAY..producer p
ORDER by p.name