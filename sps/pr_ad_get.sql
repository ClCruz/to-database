ALTER PROCEDURE dbo.pr_ad_get (@id UNIQUEIDENTIFIER)

AS


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
  FROM [dbo].[ad]
WHERE id=@id