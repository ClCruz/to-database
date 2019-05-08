CREATE PROCEDURE dbo.pr_partner_uniquename_bykey (@api VARCHAR(1000))

AS

SELECT TOP 1
p.uniquename
FROM CI_MIDDLEWAY..[partner] p
WHERE p.[key]=@api OR p.key_test=@api