CREATE PROCEDURE dbo.pr_admin_partner_whitelabel_git_save (@id_partner UNIQUEIDENTIFIER
                                                            ,@started BIT)
AS


SET NOCOUNT ON;

DECLARE @uniquename varchar(1000)
        ,@has BIT = 0
        ,@id UNIQUEIDENTIFIER

SELECT @has = 1, @id=wlge.id FROM CI_MIDDLEWAY.dbo.whitelabelgitexecute wlge WHERE wlge.id_partner=@id_partner AND wlge.ended IS NULL

SELECT @uniquename=uniquename FROM CI_MIDDLEWAY.dbo.[partner] WHERE id=@id_partner

IF @started = 1
BEGIN
    SET @has = 0;
END

IF @has = 1 
BEGIN
    UPDATE CI_MIDDLEWAY.dbo.whitelabelgitexecute
    SET ended=GETDATE()
    WHERE id=@id
END
ELSE
BEGIN
    INSERT INTO CI_MIDDLEWAY.dbo.whitelabelgitexecute (id_partner,uniquename,[started],[ended])
    VALUES (@id_partner, @uniquename, GETDATE(), NULL)
END
