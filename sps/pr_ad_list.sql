CREATE PROCEDURE dbo.pr_ad_list (@text VARCHAR(100))

AS


SELECT [id]
      ,CONVERT(VARCHAR(10),created,103) + ' ' + CONVERT(VARCHAR(8),created,114) created
      ,[id_partner]
      ,[isactive]
      ,CONVERT(VARCHAR(10),[startdate],103) + ' ' + CONVERT(VARCHAR(8),[startdate],114) [startdate]
      ,CONVERT(VARCHAR(10),[enddate],103) + ' ' + CONVERT(VARCHAR(8),[enddate],114) [enddate]
      ,[title]
      ,[content]
      ,[link]
      ,[type]
      ,[image]
      ,[campaign]
      ,[name]
      ,[priority]
      ,[index]
  FROM [dbo].[ad]
WHERE (@text IS NULL OR name like '%'+@text+'%')
OR (@text IS NULL OR title like '%'+@text+'%')
OR (@text IS NULL OR content like '%'+@text+'%')
OR (@text IS NULL OR link like '%'+@text+'%')
ORDER BY [name]