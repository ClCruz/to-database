
CREATE PROCEDURE pr_to_admin_user_add_partner (@id_user UNIQUEIDENTIFIER, @id UNIQUEIDENTIFIER, @id_partner UNIQUEIDENTIFIER)

AS

SET NOCOUNT ON;

DECLARE @has BIT = 0
        ,@hasActive BIT = 0 

SELECT TOP 1 @has = 1, @hasActive = active FROM CI_MIDDLEWAY..to_admin_user_partner WHERE id_to_admin_user=@id AND id_partner=@id_partner

IF @has = 1
BEGIN
    IF @hasActive = 1
    BEGIN
        UPDATE CI_MIDDLEWAY..to_admin_user_partner SET active=0 WHERE id_to_admin_user=@id AND id_partner=@id_partner
    END
    ELSE
    BEGIN
        UPDATE CI_MIDDLEWAY..to_admin_user_partner SET active=1 WHERE id_to_admin_user=@id AND id_partner=@id_partner
    END

    SELECT 1 success
        ,'' msg
    
    RETURN;
END

INSERT INTO CI_MIDDLEWAY..to_admin_user_partner (id_to_admin_user, id_partner,active)
SELECT @id, @id_partner, 1

SELECT 1 success
        ,'' msg
