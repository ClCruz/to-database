
ALTER PROCEDURE dbo.pr_admin_partner_generate 
    (@id_user UNIQUEIDENTIFIER
    ,@id UNIQUEIDENTIFIER
    ,@keyTo VARCHAR(100))

AS

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#keypartner', 'U') IS NOT NULL
    DROP TABLE #keypartner; 

DECLARE @key VARCHAR(100)
        ,@key_test VARCHAR(100)

CREATE TABLE #keypartner ([key] VARCHAR(100), [key_test] VARCHAR(100));

INSERT INTO #keypartner EXEC CI_MIDDLEWAY..pr_partner_key NULL, 0;

SELECT @key=[key], @key_test=key_test FROM #keypartner

IF @keyTo = 'prod'
BEGIN
    UPDATE CI_MIDDLEWAY..[partner]
        SET [key]=@key
    WHERE
        id=@id
END
ELSE
BEGIN
    UPDATE CI_MIDDLEWAY..[partner]
        SET [key_test]=@key_test
    WHERE
        id=@id
END


