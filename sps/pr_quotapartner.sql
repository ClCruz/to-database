ALTER PROCEDURE dbo.pr_quotapartner (@loggedId UNIQUEIDENTIFIER, @search VARCHAR(100) = NULL, @api VARCHAR(1000), @currentPage INT = 1, @perPage INT = 10)

AS

SET NOCOUNT ON;

DECLARE @id_partner UNIQUEIDENTIFIER

SELECT TOP 1 @id_partner=p.id FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api

SELECT
g.id
,g.[name]
,g.[key]
,g.active
,COUNT(*) OVER() totalCount
,@currentPage currentPage
FROM CI_MIDDLEWAY..quota_partner g
WHERE (@search IS NULL OR g.name LIKE '%'+@search+'%' COLLATE SQL_Latin1_General_Cp1251_CI_AS)
AND g.id_partner=@id_partner
ORDER BY [name]
 OFFSET (@currentPage-1)*@perPage ROWS
   FETCH NEXT @perPage ROWS ONLY;