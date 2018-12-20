ALTER PROCEDURE dbo.pr_genre (@loggedId UNIQUEIDENTIFIER, @search VARCHAR(100) = NULL, @currentPage INT = 1, @perPage INT = 10)

AS

SET NOCOUNT ON;

SELECT
g.id
,g.[name]
,g.active
,COUNT(*) OVER() totalCount
,@currentPage currentPage
FROM CI_MIDDLEWAY..genre g
WHERE (@search IS NULL OR g.name LIKE '%'+@search+'%' COLLATE SQL_Latin1_General_Cp1251_CS_AS)
ORDER BY [name]
 OFFSET (@currentPage-1)*@perPage ROWS
   FETCH NEXT @perPage ROWS ONLY;