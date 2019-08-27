
CREATE PROCEDURE pr_tickettype_partner_save (@id_base INT, @CodTipBilhete INT, @id_partner UNIQUEIDENTIFIER)

AS

SET NOCOUNT ON;

DECLARE @has BIT = 0
        ,@hasActive BIT = 0 

SELECT TOP 1 @has = 1, @hasActive = active FROM CI_MIDDLEWAY..tickettype_partner WHERE id_base=@id_base AND CodTipBilhete=@CodTipBilhete AND id_partner=@id_partner

IF @has = 1
BEGIN
    IF @hasActive = 1
    BEGIN
        UPDATE CI_MIDDLEWAY..tickettype_partner SET active=0, updated=GETDATE() WHERE id_base=@id_base AND CodTipBilhete=@CodTipBilhete AND id_partner=@id_partner
    END
    ELSE
    BEGIN
        UPDATE CI_MIDDLEWAY..tickettype_partner SET active=1, updated=GETDATE() WHERE id_base=@id_base AND CodTipBilhete=@CodTipBilhete AND id_partner=@id_partner
    END

    SELECT 1 success
        ,'' msg
    
    RETURN;
END

INSERT INTO CI_MIDDLEWAY..tickettype_partner (id_base,id_partner,CodTipBilhete)
SELECT @id_base,@id_partner,@CodTipBilhete

SELECT 1 success
        ,'' msg
