ALTER PROCEDURE dbo.pr_ad_list (@text VARCHAR(100), @currentPage INT = 1, @perPage INT = 10)

AS

-- declare @text VARCHAR(100) = NULL, @currentPage INT = 1, @perPage INT = 10

SELECT [id]
  ,CONVERT(VARCHAR(10),created,103) + ' ' + CONVERT(VARCHAR(8),created,114) created
  ,[id_partner]
  ,[isactive]
  ,CONVERT(VARCHAR(10),[startdate],103) + ' ' + CONVERT(VARCHAR(5),[startdate],114) [startdate]
  ,CONVERT(VARCHAR(10),[enddate],103) + ' ' + CONVERT(VARCHAR(5),[enddate],114) [enddate]
  ,[title]
  ,[content]
  ,[link]
  ,[type]
  ,[campaign]
  ,[name]
  ,[priority]
  ,[index]
  ,COUNT(*) OVER() totalCount
  ,@currentPage currentPage
FROM [dbo].[ad]
WHERE (@text IS NULL OR name like '%'+@text+'%')
OR (@text IS NULL OR title like '%'+@text+'%')
OR (@text IS NULL OR content like '%'+@text+'%')
OR (@text IS NULL OR link like '%'+@text+'%')
ORDER BY [name]
OFFSET (@currentPage-1)*@perPage ROWS
  FETCH NEXT @perPage ROWS ONLY;