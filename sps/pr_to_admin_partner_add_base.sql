
ALTER PROCEDURE pr_to_admin_partner_add_base (@id UNIQUEIDENTIFIER, @id_base INT)

AS

SET NOCOUNT ON;

DECLARE @has BIT = 0
        ,@hasActive BIT = 0 

SELECT TOP 1 @has = 1 FROM CI_MIDDLEWAY..partner_database WHERE id_partner=@id AND id_base=@id_base

IF @has = 1
BEGIN
    DELETE CI_MIDDLEWAY..partner_database WHERE id_partner=@id AND id_base=@id_base

    SELECT 1 success
        ,'' msg
    
    RETURN;
END

INSERT INTO CI_MIDDLEWAY..partner_database (id_partner,id_base,allEvent)
SELECT @id, @id_base, 1

SELECT 1 success
        ,'' msg
