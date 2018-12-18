CREATE PROCEDURE dbo.pr_apikey (@key VARCHAR(100))

AS

DECLARE @has BIT = 0

SELECT @has = 1
FROM CI_MIDDLEWAY..[partner] p
WHERE p.[key]=@key OR p.key_test=@key

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