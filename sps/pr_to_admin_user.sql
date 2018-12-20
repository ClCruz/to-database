
ALTER PROCEDURE dbo.pr_to_admin_user (@search VARCHAR(100) = NULL, @currentPage INT = 1, @perPage INT = 10)

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
    ,COUNT(*) OVER() totalCount
    ,@currentPage currentPage
FROM CI_MIDDLEWAY..to_admin_user tau
WHERE ((@search IS NULL OR tau.name LIKE '%'+@search+'%' COLLATE SQL_Latin1_General_Cp1251_CS_AS)
OR (@search IS NULL OR tau.[login] LIKE '%'+@search+'%' COLLATE SQL_Latin1_General_Cp1251_CS_AS)
OR (@search IS NULL OR tau.email LIKE '%'+@search+'%' COLLATE SQL_Latin1_General_Cp1251_CS_AS)
OR (@search IS NULL OR tau.document LIKE '%'+@search+'%' COLLATE SQL_Latin1_General_Cp1251_CS_AS))
ORDER by tau.name
 OFFSET (@currentPage-1)*@perPage ROWS
   FETCH NEXT @perPage ROWS ONLY;