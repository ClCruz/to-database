ALTER PROCEDURE dbo.pr_login_checkpartner(@id_to_admin_user UNIQUEIDENTIFIER, @apikey VARCHAR(100))

AS

SET NOCOUNT ON;

DECLARE @id_partner UNIQUEIDENTIFIER

SELECT TOP 1 @id_partner=p.id FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@apikey OR p.key_test=@apikey

DECLARE @isOK BIT = 0

SELECT @isOK=1
FROM CI_MIDDLEWAY..to_admin_user_partner aup
WHERE
aup.id_to_admin_user=@id_to_admin_user
AND aup.id_partner=@id_partner
AND aup.active=1

-- SET @isOK=1

SELECT @isok isok
