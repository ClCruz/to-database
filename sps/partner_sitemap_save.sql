ALTER PROCEDURE dbo.partner_sitemap_save (@id_partner UNIQUEIDENTIFIER
                                        ,@success BIT
                                        ,@msg VARCHAR(100)) 

AS

SET NOCOUNT ON;

DECLARE @id UNIQUEIDENTIFIER = NULL
SELECT @id = id FROM CI_MIDDLEWAY..partner_sitemap WHERE id_partner=@id_partner

IF @id IS NULL
BEGIN
    INSERT INTO CI_MIDDLEWAY..partner_sitemap (id, created, hasError, error,id_partner,lastgenerated)
    SELECT NEWID(),GETDATE(),(CASE WHEN @success = 1 THEN 0 ELSE 1 END),(CASE WHEN @success = 1 THEN '' ELSE @msg END),@id_partner,(CASE WHEN @success = 1 THEN GETDATE() ELSE NULL END)
END
ELSE
BEGIN
    UPDATE CI_MIDDLEWAY..partner_sitemap
    SET error=(CASE WHEN @success = 1 THEN '' ELSE @msg END)
        ,hasError=(CASE WHEN @success = 1 THEN 0 ELSE 1 END)
        ,lastgenerated=(CASE WHEN @success = 1 THEN GETDATE() ELSE NULL END)
    WHERE id=@id
END
