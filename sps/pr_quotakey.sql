CREATE PROCEDURE dbo.pr_quotakey (@key VARCHAR(100))

AS

-- DECLARE @key VARCHAR(100) = 'qp_ab8665e1345545bcb8c53afaaf83d257cf574ed6b0724526aa9f1d156d730fd3'

DECLARE @has BIT = 0

SELECT @has = 1
FROM CI_MIDDLEWAY..[quota_partner] p
WHERE p.[key]=@key

IF @has = 1
BEGIN
    SELECT 1 success
            ,'key found' msg
END
ELSE
BEGIN
    SELECT 0 success
            ,'key not found' msg
END