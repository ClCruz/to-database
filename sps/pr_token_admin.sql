--exec sp_executesql N'EXEC pr_login @P1',N'@P1 varchar(8000)','blc'
GO

ALTER PROCEDURE dbo.pr_token_admin(@token VARCHAR(1000))

AS

SELECT
p.active
,p.email
,p.id
,p.document
,CONVERT(VARCHAR(10),p.lastLogin,103) + ' ' + CONVERT(VARCHAR(8),p.lastLogin,114) lastLogin
,p.[login]
,p.name
,p.[password]
,CONVERT(VARCHAR(10),p.tokenValidUntil,121) + ' ' + CONVERT(VARCHAR(8),p.tokenValidUntil,114) tokenValidUntil
,(CASE WHEN p.tokenValidUntil >= GETDATE() THEN 1 ELSE 0 END) isValid
FROM CI_MIDDLEWAY..to_admin_user p
WHERE lower(p.currentToken)=lower(@token)