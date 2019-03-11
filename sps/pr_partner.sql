ALTER PROCEDURE dbo.pr_partner (@id UNIQUEIDENTIFIER)

AS

SELECT
p.id
,CONVERT(VARCHAR(10),p.created,103) + ' ' + CONVERT(VARCHAR(8),p.created,114) created
,p.[key]
,p.key_test
,p.[name]
,p.active
,CONVERT(VARCHAR(10),p.dateStart,103) dateStart
,CONVERT(VARCHAR(10),p.dateEnd,103) dateEnd
,p.domain
,p.fb_appid
,p.recaptchaid
FROM [partner] p
WHERE p.id=@id