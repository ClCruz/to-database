CREATE PROCEDURE dbo.pr_ad_home_list (@apikey VARCHAR(100))

AS

-- DECLARE @api VARCHAR(100) = 'live_185e1621cf994a99ba945fe9692d4bf6d66ef03a1fcc47af8ac909dbcea53fb5'

DECLARE @id_partner UNIQUEIDENTIFIER

SELECT TOP 1 @id_partner=p.id FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@apikey OR p.key_test=@apikey

SELECT [id]
  ,[name]
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
  ,[priority]
  ,[index]
  ,COUNT(*) OVER() totalCount
FROM [dbo].[ad]
WHERE startdate<=GETDATE()
AND (enddate IS NULL OR enddate>=GETDATE())
AND isactive=1
AND id_partner = @id_partner
ORDER BY (CASE WHEN priority = 0 THEN 99999 ELSE priority END), NEWID()
GO
