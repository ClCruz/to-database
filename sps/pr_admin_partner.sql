ALTER PROCEDURE dbo.pr_admin_partner (@loggedId UNIQUEIDENTIFIER, @search VARCHAR(100) = NULL, @currentPage INT = 1, @perPage INT = 10)

AS

SET NOCOUNT ON;

SELECT
    p.id
    ,p.active
    ,CONVERT(VARCHAR(10),p.created,103) created
    ,(CASE WHEN p.dateEnd IS NULL THEN '' ELSE CONVERT(VARCHAR(10),p.dateEnd,103) END) dateEnd
    ,CONVERT(VARCHAR(10),p.dateStart,103) dateStart
    ,p.domain
    ,p.[key]
    ,p.key_test
    ,p.name
    ,p.isDemo
    ,p.isTrial
    ,p.isDev
    ,p.uniquename
    ,COUNT(*) OVER() totalCount
    ,@currentPage currentPage
FROM CI_MIDDLEWAY..[partner] p
WHERE 
((@search IS NULL OR p.name LIKE '%'+@search+'%' COLLATE SQL_Latin1_General_Cp1251_CS_AS)
OR (@search IS NULL OR p.domain LIKE '%'+@search+'%' COLLATE SQL_Latin1_General_Cp1251_CS_AS)
OR (@search IS NULL OR p.[key] LIKE '%'+@search+'%' COLLATE SQL_Latin1_General_Cp1251_CS_AS)
OR (@search IS NULL OR p.[key_test] LIKE '%'+@search+'%' COLLATE SQL_Latin1_General_Cp1251_CS_AS))
ORDER by p.name
 OFFSET (@currentPage-1)*@perPage ROWS
   FETCH NEXT @perPage ROWS ONLY;